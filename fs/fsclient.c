#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>

#include <assert.h>
#include <signal.h>
#include <stdbool.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/wait.h>

#include <getopt.h>

#include "../include/ipckeys.h"
#include "../include/params.h"

#include "../include/fs_types.h"
#include "../include/fscom.h"


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
		if (!name) continue;

		if (name[0] == '*') continue;

		char *flags = strtok(NULL, delim);
		if (!flags) continue;

		// We only care about commands that require X11
		bool use_x = strchr(flags, 'x') != NULL;
		if (!use_x) continue;

		// strip off '&' if there is one
		char *cmd = strtok(NULL, "&");
		if (!cmd) continue;

		pid_t pid = fork();
		if (pid < 0) return -1;
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

const char *usage_short_str = "Usage: %s [-sxwfh] \n";
const char *usage_long_str =  "Usage: %s [-sxwfh] \n"
"Connect to local Field System server, starting any X11 programs\n"
"in fspgm.ctl or stpgm.ctl\n"
"  -s, --scrollback      print full scrollback buffer on connect\n"
"  -x, --no-x            do not start programs requring X11\n"
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
		{"no-x",       no_argument, NULL, 'x'},
		{"help",       no_argument, NULL, 'h'},
		{NULL, 0, NULL, 0}
	};

	// TODO: check if X11 available
	// TODO: todo add CLI flag

	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "swfxh", long_options,
	                           &option_index)) != -1) {
		switch (opt) {
			case 0:
				// All long options are flags which are handled by getopt_long
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
			case 'x':
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
			fprintf(stderr, "Field System not running, run \"fs\" first\n");
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

	if (!arg_no_x) {
		// Start other programs
        int ret;
		ret = run_pgm_ctl(FSPGM_CTL);
		if (ret < 0) exit(EXIT_FAILURE);

		ret = run_pgm_ctl(STPGM_CTL);
		if (ret < 0) exit(EXIT_FAILURE);
	}

	pid_t child;
	while ((child = wait(NULL)) > 0) {
		// If ssub shutsdown, kill all programs
		if (child == ssub_pid) {
			// Ignore SIGTERM so fsclient can shutdown cleanly
			sigset_t signal_set;
			sigemptyset(&signal_set);
			sigaddset(&signal_set, SIGTERM);
			sigprocmask(SIG_BLOCK, &signal_set, NULL);

			killpg(0, SIGTERM);
			return 0;
		}
	}
}
