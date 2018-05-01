#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include <errno.h>

#include <assert.h>
#include <signal.h>
#include <stdbool.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/wait.h>

#include <getopt.h>
#include <pthread.h>

#include "../include/ipckeys.h"
#include "../include/params.h"

#include "../include/fs_types.h"
#include "../include/fscom.h"

/* split string into two, adding null terminator
 * to input and returning second half (if any)*/
char *strsplit(char *in, char delim) {
	char *out = in;
	while (*out && *out != delim)
		out++;
	if (*out)
		*out++ = '\0';
	return out;
}

/* Kill all children processes with SIGTERM */
void kill_children() {
	/* Ignore SIGTERM so fsclient can shutdown cleanly */
	sigset_t signal_set;
	sigemptyset(&signal_set);
	sigaddset(&signal_set, SIGQUIT);
	sigprocmask(SIG_BLOCK, &signal_set, NULL);
	killpg(0, SIGQUIT);
}

/* watch a child pid and exit. Also reaps zombie processes.  */
void *exit_with(void *arg) {
	pid_t pid = *((pid_t *)arg);
	pid_t child;
	while ((child = wait(NULL)) > 0) {
		if (child == pid) {
			break;
		}
	}
	kill_children();
	exit(EXIT_SUCCESS);
}

void print_client_commands() {
	char *line = NULL;
	size_t len = 0;
	FILE *fp   = fopen(CLPGM_CTL, "r");
	if (!fp) {
		fprintf(stderr, "oprin: error opening %s: %s\n", CLPGM_CTL,
		        strerror(errno));
		return;
	}
	while (getline(&line, &len, fp) > 0) {
		if (line[0] == '\0' || line[0] == '\n' || line[0] == '*')
			continue;
		char *ptr = line;
		while (!isspace(*ptr))
			ptr++;
		*ptr = '\0';
		fprintf(stderr, "%s\n", line);
	}

	free(line);
	fclose(fp);
}

/* Lookup commands in the file found at CLPGM_CTL and
 * pass to system(3).
 *
 * Understands flags in CLPGM_CTL:
 *
 *    a    start attached to to client, ie ends with client
 *    d    start detached, ie don't exit with client
 *
 * */
void run_clpgm_ctl(const char *cmd) {
	if (!cmd || cmd[0] == '\0') {
		fprintf(stderr, "fsclient: commands are\n");
		print_client_commands();
		return;
	}

	FILE *fp = fopen(CLPGM_CTL, "r");
	if (!fp) {
		fprintf(stderr, "fsclient: error opening %s: %s\n", CLPGM_CTL,
		        strerror(errno));
		return;
	}

	char *line    = NULL;
	size_t len    = 0;
	char *flags   = NULL;
	char *command = NULL;
	while (getline(&line, &len, fp) > 0) {
		if (line[0] == '\0' || line[0] == '\n' || line[0] == '*')
			continue;
		char *name = NULL;

		char *ptr = line;

		while (isspace(*ptr))
			ptr++;

		name = ptr;
		while (!isspace(*ptr))
			ptr++;
		while (isspace(*ptr))
			*ptr++ = '\0';

		if (strcmp(cmd, name) != 0)
			continue;

		flags = ptr;
		while (!isspace(*ptr))
			ptr++;
		while (isspace(*ptr))
			*ptr++ = '\0';

		command = ptr;

		break;
	}
	fclose(fp);

	if (!command) {
		fprintf(stderr, "fsclient: unknown command \"%s\"\n", cmd);
		return;
	}

	switch (fork()) {
	case -1:
		perror("fsclient: error creating new process");
	/* fall-through */
	case 0:
		break;
	default:
		free(line);
		return;
	}

	switch (flags[0]) {
	case 'd':
		if(fork()) _exit(EXIT_SUCCESS);
		if (setsid() < 0) {
			perror("fsclient: error starting a new session");
		}
		break;
	case 'a':
		break;
	default:
		fprintf(stderr, "unknown flag %c", flags[0]);
		exit(EXIT_SUCCESS);
	}

	execl("/bin/sh", "sh", "-c", command, NULL);
}

const char *delim = " \t";
// Read a '*pgm.ctl' file (where * is 'fs' or 'stn')
int run_pgm_ctl(char *path) {
	FILE *fp = fopen(path, "r");
	if (!fp) {
		fprintf(stderr, "fsclient: error opening %s: %s\n", path,
		        strerror(errno));
		return -1;
	}

	char *line = NULL;
	size_t len = 0;
	ssize_t read;

	int i = 0;

	while ((read = getline(&line, &len, fp)) > 0) {
		char *name = strtok(line, delim);
		if (!name)
			continue;

		if (name[0] == '*')
			continue;

		char *flags = strtok(NULL, delim);
		if (!flags)
			continue;

		// We only care about commands that require X11
		bool use_x = strchr(flags, 'x') != NULL;
		if (!use_x)
			continue;

		// strip off '&' if there is one
		char *cmd = strtok(NULL, "&");
		if (!cmd)
			continue;

		pid_t pid = fork();
		if (pid < 0)
			return -1;
		if (pid == 0) {
			execlp("sh", "sh", "-c", cmd, NULL);
			perror("fsclient: error on exec");
			return -1;
		}
		i++;
	}

	free(line);
	fclose(fp);

	return i;
}

// clib
int nsem_test(char *);
void setup_ids();

const char *usage_short_str = "Usage: %s [-snwfh] \n";
const char *usage_long_str =
    "Usage: %s [-sxwfh] \n"
    "Connect to local Field System server, starting any X11 programs\n"
    "in fspgm.ctl or stpgm.ctl\n"
    "  -s, --scrollback      print full scrollback buffer on connect\n"
    "  -n, --no-x            do not start programs requring X11\n"
    "  -w, --wait            wait for Field System to restart on exit\n"
    "  -f, --force           start even if Field System is not running\n"
    "  -h, --help            print this message\n";

int main(int argc, char **argv) {
	bool arg_scrollback = false;
	bool arg_wait       = false;
	bool arg_force      = false;
	bool arg_no_x       = false;

	static struct option long_options[] = {
	    {"scrollback", no_argument, NULL, 's'},
	    {"wait",       no_argument, NULL, 'w'},
	    {"force",      no_argument, NULL, 'f'},
	    {"no-x",       no_argument, NULL, 'n'},
	    {"help",       no_argument, NULL, 'h'},
	    {NULL, 0, NULL, 0}};

	// TODO: check if X11 available
	// TODO: todo add CLI flag

	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "swfnh", long_options,
	                          &option_index)) != -1) {
		switch (opt) {
		case 0:
			// All long options are flags which are handled by
			// getopt_long
			break;
		case 's':
			arg_scrollback = true;
			break;
		case 'w':
			arg_wait = true;
			break;
		case 'f':
			arg_force = true;
			break;
		case 'n':
			arg_no_x = true;
			break;
		case 'h':
			fprintf(stderr, usage_long_str, argv[0]);
			exit(0);
			break;
		default: /* '?' */
			fprintf(stderr, usage_short_str, argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	if (!arg_force) {
		setup_ids();
		if (!nsem_test("fs   ")) {
			fprintf(stderr,
			        "Field System not running, run \"fs\" first\n");
			exit(1);
		}
	}

	// Start ssub
	int ssub_nargs     = 0;
	char *ssub_argv[6] = {NULL};

	ssub_argv[ssub_nargs++] = "ssub";
	if (arg_scrollback) ssub_argv[ssub_nargs++] = "-s";
	if (arg_wait)       ssub_argv[ssub_nargs++] = "-w";

	ssub_argv[ssub_nargs++] = FS_DISPLAY_PUBADDR;
	ssub_argv[ssub_nargs++] = FS_DISPLAY_REPADDR;

	pid_t ssub_pid = fork();
	if (ssub_pid < 0) {
		perror("fsclient: error forking");
		exit(1);
	}
	if (ssub_pid == 0) {
		execvp("ssub", ssub_argv);
		perror("fsclient: error starting ssub");
		exit(1);
	}

	// If ssub terminates, terminate client
	pthread_t wait_thread;
	if (pthread_create(&wait_thread, NULL, exit_with, &ssub_pid) != 0) {
		perror("fsclient: error on pthread_create");
		exit(EXIT_FAILURE);
	}

	char buf[256];
	int fds[2];

	if (pipe(fds) < 0) {
		perror("fsclient: error pipe");
		exit(EXIT_FAILURE);
	}

	snprintf(buf, sizeof(buf), "%d", fds[1]);
	if (setenv("FS_CLIENT_PIPE_FD", buf, 1) < 0) {
		perror("fsclient: error setenv");
		exit(EXIT_FAILURE);
	}

	if (!arg_no_x) {
		// Start other programs
		int ret;
		ret = run_pgm_ctl(STPGM_CTL);
		if (ret < 0)
			exit(EXIT_FAILURE);
		ret = run_pgm_ctl(FSPGM_CTL);
		if (ret < 0)
			exit(EXIT_FAILURE);

	}

	close(fds[1]);

	char *command = NULL;
	ssize_t len;
	size_t n;
	FILE *f = fdopen(fds[0], "r");

	while ((len = getline(&command, &n, f)) >= 0) {
		if (command[len - 1] == '\n') {
			command[len - 1] = '\0';
			len--;
		}

		if (strcasecmp(command, "exit") == 0) {
			kill_children();
			exit(EXIT_SUCCESS);
		}
		run_clpgm_ctl(command);
	}
	free(command);

	/* Only get here if pipe closed, i.e all
	 * children other than ssub exited.
	 *
	 * Keep running until ssub exits */
	pthread_join(wait_thread, NULL);
	exit(EXIT_SUCCESS);
}
