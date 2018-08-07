#include "convey.h"
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include "../window.h"

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

	int fd = open(w->pubaddr + 6, O_WRONLY | O_CREAT, 0660);
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

Main({
	Test("Window operations", {
		window_t *w = window_new();
		Convey("allocation works", { So(w != NULL); });
		w->id             = 1;
		w->pubaddr        = strdup("ipc:///tmp/testpub");
		w->repaddr        = strdup("ipc:///tmp/reppub");
		w->master_handler = dummy_manger;
		Convey("Given new window", {
			Convey("unknown child commands are handled", {
				w->command = strdup("thiscommandshouldnotexist");
				So(window_start_child(w) == -1 && errno == ENOENT);
			});

			Convey("start master works", {
				w->command = strdup("watch ls");
				int pty    = window_start_child(w);
				So(w->pid > 0);
				So(pty >= 0);
				int master_pid = window_start_master(w, pty);
				So(master_pid > 0);
				window_kill(w);
				kill(master_pid, SIGTERM);
				window_free(w);
			});
		});
	});

	Test("Window list operations", {
		Convey("Given empty list", {
			window_list_t *wl = NULL;

			Convey("we can append", {
				window_t *w = window_new();
				w->id       = 1;
				window_list_append(&wl, w);
				So(wl != NULL);
				So(wl->window != NULL);
				So(wl->window->id == 1);

				w = window_new();
				So(w != NULL);
				w->id = 2;
				window_list_append(&wl, w);

				Convey("and window list preserves order", {
					So(wl->window->id == 1);
					So(wl->next->window->id == 2);
				});

				Convey("find by id works", {
					w = window_list_find_by_id(&wl, 1);
					So(w != NULL);
					So(w->id == 1);
					w = window_list_find_by_id(&wl, 2);
					So(w != NULL);
					So(w->id == 2);
				});

				Convey("find by id handles not found",
				       { So(window_list_find_by_id(&wl, 3) == NULL); });

				Convey("pop works", {
					w = window_list_pop(&wl);
					So(w != NULL);
					So(w->id == 1);
					w = window_list_pop(&wl);
					So(w != NULL);
					So(w->id == 2);
					w = window_list_pop(&wl);
					So(w == NULL);
				});

				Convey("pop by id works", {
					w = window_list_pop_by_id(&wl, 2);
					So(w != NULL);
					So(w->id == 2);
					So(wl->next == NULL);
					window_free(w);
				});

				Convey("pop can handle missing element", {
					window_list_pop_by_id(&wl, 2);
					w = window_list_pop_by_id(&wl, 2);
					So(w == NULL);
				});

				Convey("pop can empty list ", {
					window_list_pop_by_id(&wl, 1);
					window_list_pop_by_id(&wl, 2);
					So(wl == NULL);
				});

				Convey("Given a running window", {
					w                 = window_list_find_by_id(&wl, 2);
					w->pubaddr        = strdup("ipc:///tmp/testpub");
					w->repaddr        = strdup("ipc:///tmp/reppub");
					w->command        = strdup("watch ls");
					w->master_handler = dummy_manger;

					int pty = window_start_child(w);
					So(pty >= 0);
					int master_pid = window_start_master(w, pty);
					So(master_pid >= 0);
					int pid = w->pid;
					So(pid >= 0);

					Reset({
						window_kill(w);
						kill(master_pid, SIGTERM);
					});

					Convey("find by pid works", {
						w = window_list_find_by_pid(&wl, pid);
						So(w != NULL);
						So(w->id = 2);
						So(w->pid = pid);
					});
					Convey("pop by pid works", {
						So(pid >= 0);
						w = window_list_pop_by_pid(&wl, pid);
						So(w != NULL);
						So(w->id = 2);
						So(w->pid = pid);
						window_kill(w);
					})
				});
			});
		});
	});
});
