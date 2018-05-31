#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <pthread.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "../include/ipckeys.h"
#include "../include/params.h"

#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;
void helpstr_(const char *cnam, int *clength, char *runstr, int *rack,
              int *drive1, int *drive2, int *ierr, int clen, int rlen);

volatile sig_atomic_t die   = 0;
volatile sig_atomic_t child = 0;

void handler(int sig) {
	switch (sig) {
	case SIGTERM:
	case SIGINT:
	case SIGQUIT:
		die = sig;
		break;
	case SIGCHLD:
		child = 1;
		break;
	}
}

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

void fatal(const char *msg) {
	perror(msg);
	exit(EXIT_FAILURE);
}

/* Kill all children processes with SIGINT */
void kill_children() {
	/* Ignore SIGINT so fsclient can shutdown cleanly */
	__sighandler_t p;
	if ((p = signal(SIGINT, SIG_IGN)) == SIG_ERR)
		fatal("fsclient: error killing children");
	if (killpg(0, SIGINT) < 0)
		fatal("fsclient: error killing children");
	if (signal(SIGINT, p) == SIG_ERR)
		fatal("fsclient: error killing children");
}

void help(const char *arg) {
	char help_file[256] = {0};

	int err = 0;
	int i   = (int)(strlen(arg));
	/* TODO: this may cause problems on 64 bit */

	helpstr_(arg, &i, help_file, &shm_addr->equip.rack,
	         &shm_addr->equip.drive[0], &shm_addr->equip.drive[1], &err, 0,
	         0);

	if (err == -3) {
		fprintf(stderr, "fsclient: could not find help for \"%s\"\n",
		        arg);
		return;
	}

	if (err == -2) {
		fprintf(stderr, "fsclient: help string too long");
		return;
	}

	if (err < 0) {
		fprintf(stderr, "fsclient: unknown error %d", err);
		return;
	}

	sigset_t set;

	switch (fork()) {
	case -1:
		fatal("fsclient: error forking");
	case 0:

		sigemptyset(&set);
		sigprocmask(SIG_SETMASK, &set, NULL);

		execlp("helpsh", "helpsh", help_file, NULL);
		perror("fsclient: error opening helpsh");
		_exit(EXIT_FAILURE);
	default:
		return;
	}
}

/* Signal handler thread.
 * Watches the pid given in arg and executes a clean shutdown if it dies.
 * Also reaps zombie processes and handles terminate signals.
 */
void *signal_thread_fn(void *arg) {
	pid_t shudown_pid = *((pid_t *)arg);

	// Assuming mask inherited from main thread is totally blocked

	sigset_t set, emptyset;

	sigfillset(&set);
	pthread_sigmask(SIG_SETMASK, &set, NULL);
	while (!die) {
		sigemptyset(&emptyset);
		int ret = pselect(0, NULL, NULL, NULL, NULL, &emptyset);

		if (ret == -1 && errno != EINTR) {
			fatal("fsclient pselect error");
		}

		if (child) {
			child = 0;
			if (signal(SIGCHLD, handler) == SIG_IGN)
				fatal("fsclient: error setting signal handler");
			for (;;) {
				pid_t pid = waitpid(-1, NULL, WNOHANG);
				if (pid < 0 && errno != ECHILD) {
					fatal("poll");
				}

				if (pid <= 0) {
					break;
				}

				if (pid == shudown_pid) {
					die = -1;
				}
			}
		}
	}
	if (die > 0) {
		// Killed by a signal, not main child
		fprintf(stderr, "\nclient exiting...\n");
	}
	kill_children();
	exit(EXIT_SUCCESS);
}

void print_client_commands() {
	char *line = NULL;
	size_t len = 0;
	FILE *fp   = fopen(CLPGM_CTL, "r");
	if (!fp) {
		fprintf(stderr, "fsclient: error opening %s: %s\n", CLPGM_CTL,
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
		printf("%s\n", line);
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
		printf("fsclient commands are:\n");
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
	default:
		free(line);
		return;
	case 0:
		break;
	case -1:
		fatal("fsclient: error creating new process");
	}

	switch (flags[0]) {
	case 'd':
		if (setsid() < 0) {
			perror("fsclient: error starting a new session");
			_exit(EXIT_FAILURE);
		}
		switch (fork()) {
		default:
			_exit(EXIT_SUCCESS);
		case 0:
			break;
		case -1:
			fatal("fsclient: error creating new process");
		}

		break;
	case 'a':
		break;
	default:
		fprintf(stderr, "fsclient: error starting command %s, unknown flag '%c'", command, flags[0]);
		_exit(EXIT_SUCCESS);
	}

	sigset_t set;
	sigemptyset(&set);
	sigprocmask(SIG_SETMASK, &set, NULL);

	execl("/bin/sh", "sh", "-c", command, NULL);
	perror("fsclient: error running command");
	_exit(EXIT_FAILURE);
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

			sigset_t set;
			sigemptyset(&set);
			sigprocmask(SIG_SETMASK, &set, NULL);
			execlp("sh", "sh", "-c", cmd, NULL);
			perror("fsclient: error on exec");
			_exit(EXIT_FAILURE);
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

const char *usage_short_str = "Usage: %s [-swfnh] \n";
const char *usage_long_str =
    "Usage: %s [-swfnh] \n"
    "Connect to local Field System server, starting any X11 programs\n"
    "in fspgm.ctl or stpgm.ctl\n"
    "  -s, --scrollback      print full scrollback buffer on connect\n"
    "  -w, --wait            wait for Field System to restart on exit\n"
    "  -f, --force           start even if Field System is not running\n"
    "  -n, --no-x            do not start programs requring X11\n"
    "  -h, --help            print this message\n";

// clang-format off
static struct option long_options[] = {
    {"scrollback", no_argument, NULL, 's'},
    {"wait",       no_argument, NULL, 'w'},
    {"force",      no_argument, NULL, 'f'},
    {"no-x",       no_argument, NULL, 'n'},
    {"help",       no_argument, NULL, 'h'},
    {NULL, 0, NULL, 0}};
// clang-format on

int main(int argc, char **argv) {
	bool arg_scrollback = false;
	bool arg_wait       = false;
	bool arg_force      = false;
	bool arg_no_x       = false;

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
			printf(usage_long_str, argv[0]);
			exit(EXIT_SUCCESS);
			break;
		default: /* '?' */
			fprintf(stderr, usage_short_str, argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	setup_ids();
	if (!arg_force && !nsem_test("fs   ")) {
		fprintf(stderr, "Field System not running, run \"fs\" first\n");
		exit(EXIT_FAILURE);
	}

	if (signal(SIGINT, handler) == SIG_ERR ||
	    signal(SIGQUIT, handler) == SIG_ERR ||
	    signal(SIGTERM, handler) == SIG_ERR ||
	    signal(SIGCHLD, handler) == SIG_ERR) {
		fatal("fsclient: error setting signals");
	}

	int ssub_nargs     = 0;
	char *ssub_argv[6] = {NULL};

	ssub_argv[ssub_nargs++] = "ssub";
	if (arg_scrollback)
		ssub_argv[ssub_nargs++] = "-s";
	if (arg_wait)
		ssub_argv[ssub_nargs++] = "-w";

	ssub_argv[ssub_nargs++] = FS_DISPLAY_PUBADDR;
	ssub_argv[ssub_nargs++] = FS_DISPLAY_REPADDR;

	pid_t ssub_pid = fork();
	if (ssub_pid < 0) {
		fatal("fsclient: error forking");
	}
	if (ssub_pid == 0) {
		execvp("ssub", ssub_argv);
		perror("fsclient: error starting ssub");
		_exit(EXIT_FAILURE);
	}

	int fds[2];

	if (pipe(fds) < 0) {
		fatal("fsclient: error on pipe");
	}

	// children shouldn't be reading from the pipe
	if (fcntl(fds[0], F_SETFD, fcntl(fds[0], F_GETFD) | FD_CLOEXEC) < 0) {
		fatal("fsclient: error setting close-on-exec flag");
	}

	char buf[256];
	snprintf(buf, sizeof(buf), "%d", fds[1]);
	if (setenv("FS_CLIENT_PIPE_FD", buf, 1) < 0) {
		perror("fsclient: error setenv");
		exit(EXIT_FAILURE);
	}

	if (!arg_no_x) {
		// Start other programs
		int ret;
		ret = run_pgm_ctl(FSPGM_CTL);
		if (ret < 0)
			fatal("fsclient: error starting fs programs");
		ret = run_pgm_ctl(STPGM_CTL);
		if (ret < 0)
			fatal("fsclient: error starting station programs");
	}

	close(fds[1]);

	// signals are handled by other thread, block in this thread
	sigset_t set;
	sigfillset(&set);
	pthread_sigmask(SIG_BLOCK, &set, NULL);

	// setup signal  ssub terminates, terminate client
	pthread_t signal_thread;
	if (pthread_create(&signal_thread, NULL, signal_thread_fn, &ssub_pid)) {
		fatal("fsclient: error on pthread_create");
	}

	char *command = NULL;
	char *arg     = NULL;
	ssize_t len;
	size_t n;
	FILE *f = fdopen(fds[0], "r");

	while ((len = getline(&command, &n, f)) >= 0) {
		if (command[len - 1] == '\n') {
			command[len - 1] = '\0';
			len--;
		}

		arg = strsplit(command, '=');

		if (strcasecmp(command, "exit") == 0) {
			kill_children();
			exit(EXIT_SUCCESS);
		}

		if (strcasecmp(command, "help") == 0) {
			help(arg);
			continue;
		}

		// Lookup in clpgm.ctl
		// args aren't used here. Perhaps in the future?
		run_clpgm_ctl(command);
	}
	free(command);

	/* Only get here if pipe closed, i.e all
	 * children other than ssub exited.
	 *
	 * Keep running until ssub exits */
	pthread_join(signal_thread, NULL);
	exit(EXIT_SUCCESS);
}
