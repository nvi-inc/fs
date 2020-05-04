/*
 * Copyright (c) 2020 NVI, Inc.
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
#include "convey.h"
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include "../window.c"

int dummy_manger(window_t *w, int pty_master) {
	/* pipe used to handle exec error in child */
	int pipefd[2];

	if (pipe(pipefd) == -1)
		return -1;

	pid_t spubpid = fork();
	if (spubpid < 0)
		return -1;

	if (spubpid > 0) {
		if (close(pipefd[1]) < 0) {
			return -1;
		}

		int child_errno = 0;
		while (read(pipefd[0], &child_errno, sizeof(child_errno)) > 0) {
		}

		if (close(pipefd[0]) < 0) {
			return -1;
		}

		if (child_errno != 0) {
			errno = child_errno;
			perror("exec");
			return -1;
		}

		return spubpid;
	}

	if (close(pipefd[0]) != 0)
		goto error;

	/* Close write on exec, signaling to parent successful exec */
	if (fcntl(pipefd[1], F_SETFD, FD_CLOEXEC) < 0) {
		goto error;
	}

	if (dup2(pty_master, STDIN_FILENO) < 0) {
		goto error;
	}

	int fd = open(w->addr + 6, O_WRONLY | O_CREAT, 0660);
	if (fd < 0) {
		goto error;
	}
	if (dup2(fd, STDOUT_FILENO) < 0) {
		goto error;
	}

	execlp("cat", "cat", "-", NULL);

error:
	write(pipefd[1], &errno, sizeof(errno));
	_exit(EXIT_FAILURE);
}

char *non_exist_args[] = {"thiscommandshouldnotexist", NULL};
char *watch_args[]     = {"watch", "ls", NULL};

static char **stradup(char **argv) {
	char **ptr = argv;
	while (*ptr != NULL)
		ptr++;
	size_t len = ptr - argv;

	char **ret = calloc(len + 1, sizeof(char *));
	char **to  = ret;

	char **from = argv;
	size_t n    = 0;
	while (n < len && *from) {
		*to++ = strdup(*from++);
		n++;
	}
	return ret;
}

Main({
	Test("Window operations", {
		window_t *w = window_new();
		Convey("allocation works", {
			So(w != NULL);
			window_free(w);
		});
		w->id             = 1;
		w->addr           = strdup("ipc:///tmp/testpub");
		w->master_handler = dummy_manger;
		Convey("unknown child commands are handled", {
			w->command_args = stradup(non_exist_args);
			So(window_start_child(w) == -1 && errno == ENOENT);
			window_free(w);
		});

		Convey("start master works", {
			w->command_args = stradup(watch_args);
			int pty         = window_start_child(w);
			So(w->pid > 0);
			So(pty >= 0);
			int master_pid = window_start_master(w, pty);
			So(master_pid > 0);
			window_kill(w);
			kill(master_pid, SIGTERM);
			window_free(w);
		});

		window_free(w);
	});
});
// TODO: test this again
/* Convey("Given a running ", { */
/* 	w                 = _list_find_by_id(&wl, 2); */
/* 	w->pubaddr        = strdup("ipc:///tmp/testpub"); */
/* 	w->repaddr        = strdup("ipc:///tmp/reppub"); */
/* 	w->command        = strdup("watch ls"); */
/* 	w->master_handler = dummy_manger; */
/*  */
/* 	int pty = _start_child(w); */
/* 	So(pty >= 0); */
/* 	int master_pid = _start_master(w, pty); */
/* 	So(master_pid >= 0); */
/* 	int pid = w->pid; */
/* 	So(pid >= 0); */
/*  */
/* 	Reset({ */
/* 		_kill(w); */
/* 		kill(master_pid, SIGTERM); */
/* 	}); */
/*  */
/* 	Convey("find by pid works", { */
/* 		w = list_find(&wl, pid); */
/* 		So(w != NULL); */
/* 		So(w->id = 2); */
/* 		So(w->pid = pid); */
/* 	}); */
/* 	Convey("pop by pid works", { */
/* 		So(pid >= 0); */
/* 		w = _list_pop_by_pid(&wl, pid); */
/* 		So(w != NULL); */
/* 		So(w->id = 2); */
/* 		So(w->pid = pid); */
/* 	}) */
/* }); */
