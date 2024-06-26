/*
 * Copyright (c) 2020-2021, 2024 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <errno.h>
#include <fcntl.h>
#include <linux/limits.h>
#include <pthread.h>
#include <pwd.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include <jansson.h>
#include <nng/nng.h>
#include <nng/protocol/reqrep0/req.h>
#include <nng/supplemental/util/platform.h>

#include "../include/params.h"

#include "jsonutils.h"
#include "server.h"

static bool opt_daemon = true;

// error_fd is set to write end of pipe in the daemon process, which can be
// used to send an message to the calling process if an error occurs early in
// the startup of the daemon.
static int error_fd = -1;

#define fatal(msg, s)                                                                              \
	do {                                                                                       \
		if (opt_daemon && error_fd != -1) {                                                \
			FILE *f = fdopen(error_fd, "w");                                           \
			fprintf(f, "%s:%d (%s) error %s: %s\n", __FILE__, __LINE__, __FUNCTION__,  \
			        msg, s);                                                           \
			fclose(f);                                                                 \
			exit(1);                                                                   \
		}                                                                                  \
		fprintf(stderr, "%s:%d (%s) error %s: %s\n", __FILE__, __LINE__, __FUNCTION__,     \
		        msg, s);                                                                   \
		exit(1);                                                                           \
	} while (0)

int cli_main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("what's the command?\n");
		exit(EXIT_FAILURE);
	}

	nng_socket server_cmd_sock;
	int rv;

	if ((rv = nng_req0_open(&server_cmd_sock)) != 0) {
		fatal("unable to open open a socket", nng_strerror(rv));
	}

	if ((rv = nng_dial(server_cmd_sock, FS_SERVER_URL_BASE "/cmd", NULL, 0)) != 0) {
		fatal("unable to connect to server", nng_strerror(rv));
	}

	json_t *json = json_object();
	json_object_set_new(json, "method", json_string(argv[1]));
	time_t t;
	srand((unsigned)time(&t));
	json_object_sprintf(json, "id", "cli-%d", rand());

	json_t *json_args = json_array();

	for (int i = 2; i < argc; i++) {
		json_array_append_new(json_args, json_string(argv[i]));
	}
	json_object_set_new(json, "params", json_args);

	size_t size = json_dumpb(json, NULL, 0, 0);
	char *buf   = nng_alloc(size);
	if (buf == NULL) {
		fatal("unable to allocate a new message", nng_strerror(rv));
	}

	json_dumpb(json, buf, size, 0);
	json_decref(json);

	rv = nng_send(server_cmd_sock, buf, size, NNG_FLAG_ALLOC);
	if (rv != 0) {
		fatal("unable to send message to server", nng_strerror(rv));
	}

	nng_msg *msg;
	rv = nng_recvmsg(server_cmd_sock, &msg, 0);
	if (rv != 0) {
		fatal("error receiving message", nng_strerror(rv));
	}

	nng_close(server_cmd_sock);

	if (nng_msg_len(msg) == 0) {
		fprintf(stderr, "server did not reply\n");
		return 1;
	}

	char *body = nng_msg_body(msg);

	if (body[nng_msg_len(msg)] != '\0') {
		nng_msg_append(msg, "\0", 1);
		body = nng_msg_body(msg);
	}

	json_error_t err;
	json = json_loads(body, 0, &err);
	if (!json_is_object(json)) {
		fprintf(stderr, "server reply malformed: %s\n", err.text);
		goto error;
	}

	json_dumpf(json, stdout, JSON_INDENT(1));
	printf("\n");

	int ret             = 0;
	json_t *reply_error = json_object_get(json, "error");
	if (reply_error) {
		ret = 1;
	}

	json_decref(json);
	nng_msg_free(msg);
	return ret;

error:
	json_decref(json);
	nng_msg_free(msg);
	return EXIT_FAILURE;
}

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

/*
 * setup_signals sets installs the signal hander for terminate signals and SIGCHLD, and blocks all
 * signals so they can be unblocked at a sensible time to prevent a race condition, eg in pselect.
 */

void setup_signals() {
	sigset_t fullset = {};
	sigfillset(&fullset);
	pthread_sigmask(SIG_BLOCK, &fullset, NULL);

	struct sigaction sa = {};
	sa.sa_handler       = handler;
	sigfillset(&sa.sa_mask);

	if (sigaction(SIGINT, &sa, NULL) != 0 || sigaction(SIGQUIT, &sa, NULL) != 0 ||
	    sigaction(SIGTERM, &sa, NULL) != 0 || sigaction(SIGCHLD, &sa, NULL) != 0) {
		fatal("setting signals", strerror(errno));
	}
}

/*
 * daemonize makes a new session for the calling process and uses the double fork trick to ensure
 * process has no controlling terminal.
 *
 * In daemon process, returns with a file descriptor that can be written to on error of close on
 * success. Never returns in calling process.
 */

int daemonize() {
	int fds[2];

	if (pipe(fds) < 0) {
		fatal("making a pipe", strerror(errno));
	}

	pid_t spid = fork();

	if (spid < 0) {
		fatal("forking", strerror(errno));
	}

	if (spid > 0) {
		char buf[256];
		ssize_t sz;
		close(fds[1]);
		sz = read(fds[0], buf, sizeof(buf));
		if (sz < 0) {
			fatal("reading from pipe", strerror(errno));
		}
		if (sz > 0) {
			fprintf(stderr, "%.*s", (int)sz, buf);
			exit(EXIT_FAILURE);
		}

		exit(EXIT_SUCCESS);
	}

	if (close(fds[0]) < 0) {
		fatal("closing pipe", strerror(errno));
	}

	if (setsid() < 0) {
		fatal("creating a new session", strerror(errno));
	}

	spid = fork();
	if (spid < 0) {
		fatal("forking", strerror(errno));
	}

	if (spid > 0) {
		exit(EXIT_SUCCESS);
	}

	int nulldev = open("/dev/null", O_WRONLY);
	if (nulldev < 0)
		fatal("open devnul", strerror(errno));

	if (dup2(nulldev, STDIN_FILENO) < 0)
		fatal("closing fds", strerror(errno));

	return fds[1];
}

/*
 * install_shims modifies the PATH environment variable so that calls to certain X11 programs are
 * intercepted by the server.
 */
void install_shims() {
	char path[1024]     = {};
	char basepath[1024] = {};
	ssize_t sz;
	sz = readlink("/proc/self/exe", basepath, sizeof(basepath));
	if (sz < 0) {
		perror("readlink");
		exit(EXIT_FAILURE);
	}

	char *p = basepath + sz;

	while (*p != '/')
		p--;
	*p = '\0';

	char *old_path = getenv("PATH");

	if (old_path == NULL) {
		fprintf(stderr, "fsserver error: PATH not set\n");
		exit(EXIT_FAILURE);
	}

	sz = snprintf(path, sizeof(path), "%s/shims:%s", basepath, old_path);
	if (sz < 0) {
		fatal("installing shims", strerror(errno));
	}

	if ((size_t)sz >= sizeof(path)) {
		fprintf(stderr, "fsserver: error constructing PATH: too large \n");
		exit(EXIT_FAILURE);
	}

	if (setenv("PATH", path, true) < 0) {
		fatal("modifying PATH", strerror(errno));
	}
}

char *log_path() {
	char *path = NULL;
	char time_str[256];

	time_t ti         = time(NULL);
	struct tm *tm     = gmtime(&ti);
	struct passwd *pw = getpwuid(getuid());

	size_t n = strftime(time_str, sizeof(time_str), "%Y.%b.%d.%H.%M.%S", tm);
	/* the second case is supposedly for very old, <= 4.4.1 libc, and maybe some more until
	 * 4.4.4 */
	if (n == 0 || n >= sizeof(time_str))
		fatal("making fsserver.err file name", "strftime");

	if (asprintf(&path, "%s/fsserver.%s.err", pw->pw_dir, time_str) < 0)
		fatal("making fsserver.err file format string", strerror(errno));

	return path;
}

void setup_daemon_log(char *path) {
	int fd_err = open(path, O_WRONLY | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
	if (fd_err < 0) {
		fatal("opening fsserver.err file", strerror(errno));
	}

	if (dup2(fd_err, STDOUT_FILENO) < 0 || dup2(fd_err, STDERR_FILENO) < 0)
		fatal("connecting to fsserver.err file", strerror(errno));
}

void setup_foreground_log(char *path) {
	char *linep = NULL;
	if (asprintf(&linep, "/usr/bin/tee %s", path) < 0)
		fatal("making tee command", strerror(errno));

	FILE *tee = popen(linep, "w");
	if (tee == NULL)
		fatal("opening tee to fsserver.err file", strerror(errno));
	free(linep);

	if (setvbuf(tee, NULL, _IONBF, BUFSIZ))
		fatal("setting vbuf for tee to fsserver.err file", strerror(errno));

	int fd_err = fileno(tee);
	if (fd_err < 0)
		fatal("returning fileno of tee to fsserver.err file", strerror(errno));

	if (dup2(fd_err, STDOUT_FILENO) < 0 || dup2(fd_err, STDERR_FILENO) < 0)
		fatal("connecting to fsserver.err file", strerror(errno));
}

/*
 * server_main performs the task of parsing the command line arguments, initializing and configuring
 * a new server instance and monitoring UNIX signals which are passed to the server via callbacks.
 */
int server_main(int argc, char *argv[]) {
	int rv;
	if (argc > 1) {
		if (strcmp(argv[2], "-f") == 0) {
			opt_daemon = false;
		} else {
			fprintf(stderr, "unknown flag \"%s\"\n", argv[1]);
			return 1;
		}
	}
	char *log = log_path();
	if (opt_daemon) {
		setup_daemon_log(log);
		error_fd = daemonize(); // never returns in foreground process.
	} else {
		setup_foreground_log(log);
	}

	install_shims();
	setup_signals();
	umask(0007);

	server_t *s;
	rv = server_new(&s);
	if (rv != 0) {
		fatal("error creating a new server", nng_strerror(rv));
	}

	server_set_log(s, log);

	sigset_t emptyset;

	int shutdown_fd = server_finished_fd(s);
	if (shutdown_fd < 0) {
		fatal("error geting sever finished fd", strerror(errno));
	}

	rv = server_start(s);
	if (rv != 0) {
		fatal("error starting server", nng_strerror(rv));
	}

	if (error_fd != -1) {
		close(error_fd);
		error_fd = -1;
	}

	fd_set fdset;
	int maxfd = shutdown_fd;

	while (server_is_running(s)) {
		FD_ZERO(&fdset);
		FD_SET(shutdown_fd, &fdset);
		sigemptyset(&emptyset);

		int ret = pselect(maxfd + 1, &fdset, NULL, NULL, NULL, &emptyset);

		if (ret == -1 && errno != EINTR) {
			fatal("pselect", strerror(errno));
		}

		if (child) {
			child = 0;
			for (;;) {
				int status;
				pid_t pid = waitpid(-1, &status, WNOHANG);
				if (pid < 0 && errno != ECHILD) {
					fatal("waitpid faild", strerror(errno));
				}
				if (pid <= 0) {
					break;
				}
				server_sigchld_cb(s, pid, status);
			}
		}

		if (die) {
			server_sigterm_cb(s);
		}
	}

	server_destroy(s);
	return 0;
}

int main(int argc, char *argv[]) {
        if (geteuid() == 0) {
          fprintf(stderr, "The FS server cannot be run by root.\n");
          exit(255);
        }

	if (argc < 2) {
		printf("fsserver [cmd...]\n");
		printf("query the fs server\n");
		printf("\n");
		printf("generally you don't want to use this directly\n");
		return 0;
	}

	if (strcmp(argv[1], "start") == 0) {
		return server_main(argc - 1, argv++);
	}

	return cli_main(argc, argv);
}
