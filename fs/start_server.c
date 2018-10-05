#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <pty.h>
#include <utmp.h>

#include "../include/params.h"

/*
   Wraps calling process in a terminal multiplexer created by spub/ssub
   and foreground process becomes a client.

   Calling process disconnected from starting terminal and resumes
   unaffected.



                             |
       +-------------+       |         +-------------+           +-------------+
       |             |       |         |             |           |             |
       |  calling    |       |         |  calling    |    .......|    spub     |
       |  terminal   |       |         |  terminal   |    .      |             |
       |             |       |         |             |    .      +-------------+
       +-------------+       |         +-------------+    .             +
              +              |                +           .             |
              |              |                |           n             |
              |                               |           n             |
              |            ----->             |           .             |
              |         start_server          |           .             |
              v                               v           .             v
       +------------+        |         +-------------+    .      +------------+
       |            |        |         |             |    .      |            |
       |   calling  |        |         |  fsclient   |.....      |   calling  |
       |    proc    |        |         |   (ssub)    |           |    proc    |
       |            |        |         |             |           |            |
       +------------+        |         +-------------+           +------------+
                             |


 */
void start_server(bool background, bool no_x) {
	struct winsize ws;
	struct winsize *wsp = NULL;

	if (isatty(STDIN_FILENO)) {
		wsp = &ws;
		if (ioctl(0, TIOCGWINSZ, wsp) < 0) {
			perror("error getting window size");
			wsp = NULL;
		}
	}

	pid_t spid = fork();

	if (spid < 0) {
		perror("fs: error on fork");
		exit(EXIT_FAILURE);
	}

	if (spid > 0) {
		if (background) {
			exit(0);
		}
		if (no_x) {
			execlp("fsclient", "fsclient", "-sf", "-x", NULL);
		} else {
			execlp("fsclient", "fsclient", "-sf", NULL);
		}
		perror("fs: error starting fsclient");
		exit(EXIT_FAILURE);
        // TODO: wait to check if fsclient has successfully started?
	}


    // Start a new session
	if (setsid() < 0) {
		perror("fs: error creating a new session");
		exit(EXIT_FAILURE);
	}

	// Server forks calling program in a pty
	int pty_master;
	pid_t cpid = forkpty(&pty_master, NULL, NULL, wsp);
	if (cpid < 0) {
		perror("fs: error on forkpty");
		exit(EXIT_FAILURE);
	}
	if (cpid == 0) {
        // Calling process runs as usual in child
		return;
	}

    // Set stderr and stdout to close on successful exec, this way we can 
    // still report errors to the calling terminal, but disconnect from it
    // on success.
    fcntl(STDERR_FILENO, F_SETFD, FD_CLOEXEC);
    fcntl(STDOUT_FILENO, F_SETFD, FD_CLOEXEC);

	// spub expects data on stdin, redirect master end of pty to stdin
	dup2(pty_master, STDIN_FILENO);

    // TODO: add buffer length argument
	execlp("spub", "spub", "-b",
            FS_DISPLAY_SCROLLBACK_LEN,
            FS_DISPLAY_PUBADDR,
            FS_DISPLAY_REPADDR, NULL);
	perror("fs: error calling spub");
    exit(EXIT_FAILURE);
}
