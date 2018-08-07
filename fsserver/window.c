#define _GNU_SOURCE
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#ifdef __APPLE__
#include <util.h>
#elif __linux__
#include <pty.h>
#include <utmp.h>
#elif __unix__ // all unices not caught above
#include <util.h>
#elif defined(_POSIX_VERSION)
// POSIX
#else
#error "Unknown compiler"
#endif
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <wordexp.h>

#include "window.h"

void window_free(window_t *s) {
	char **ptr;
	if (s == NULL)
		return;
	if (s->command_args != NULL) {
		ptr = s->command_args;
		while (*ptr != NULL)
			free(*ptr++);
		free(s->command_args);
	}
	if (s->window_flags != NULL) {
		ptr = s->window_flags;
		while (*ptr != NULL)
			free(*ptr++);
		free(s->window_flags);
	}
	free(s->size);
	free(s->addr);
	free(s);
}

window_t *window_new() {
	window_t *s = calloc(sizeof(window_t), 1);
	return s;
}

int spub_master_handler(window_t *w, int pty_master) {
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

		/* don't want parent holding pty_master */
		close(pty_master);

		if (child_errno != 0) {
			errno = child_errno;
			return -1;
		}

		return spubpid;
	}

	if (close(pipefd[0]) < 0)
		goto error;

	/* Close write on exec, signaling to parent successful exec */
	if (fcntl(pipefd[1], F_SETFD, FD_CLOEXEC) < 0)
		goto error;
	if (dup2(pty_master, STDIN_FILENO) < 0)
		goto error;

	sigset_t emptyset;
	sigemptyset(&emptyset);
	pthread_sigmask(SIG_SETMASK, &emptyset, NULL);
	sigprocmask(SIG_SETMASK, &emptyset, NULL);

	char *sblen;
	if (asprintf(&sblen, "%d", w->scrollback_len) < 0)
		goto error;

	char *pubaddr;
	if (asprintf(&pubaddr, "%s/pub", w->addr) < 0)
		goto error;

	char *repaddr;
	if (asprintf(&repaddr, "%s/rep", w->addr) < 0)
		goto error;

	execlp("spub", "spub", "-b", sblen, pubaddr, repaddr, NULL);

error:
	write(pipefd[1], &errno, sizeof(errno));
	exit(EXIT_FAILURE);
}

size_t window_list_len(window_list_t **head) {
	assert(head != NULL);
	size_t len         = 0;
	window_list_t *ptr = *head;
	while (ptr != NULL) {
		len++;
		ptr = ptr->next;
	}
	return len;
}

void window_list_append(window_list_t **head, window_t *w) {
	window_list_t **prev_next = head;
	window_list_t *ptr        = *head;
	while (ptr != NULL) {
		prev_next = &ptr->next;
		ptr       = ptr->next;
	}

	window_list_t *new = calloc(sizeof(window_list_t), 1);
	new->window        = w;

	*prev_next = new;
}

window_t *window_list_pop(window_list_t **head) {
	assert(head != NULL);
	if (*head == NULL)
		return NULL;

	window_list_t *old_head = *head;
	window_t *w             = old_head->window;
	*head                   = (*head)->next;
	free(old_head);
	return w;
}

window_t *window_list_pop_by_id(window_list_t **head, window_id_t id) {
	assert(head != NULL);

	if (*head == NULL)
		return NULL;

	window_list_t **prev_next = head;
	window_list_t *ptr        = *head;

	while (ptr->window->id != id) {
		prev_next = &ptr->next;
		ptr       = ptr->next;
		if (ptr == NULL)
			return NULL;
	}

	*prev_next = ptr->next;

	window_t *w = ptr->window;
	free(ptr);
	return w;
}

window_t *window_list_pop_by_pid(window_list_t **head, pid_t pid) {
	assert(head != NULL);

	if (*head == NULL)
		return NULL;

	window_list_t **prev_next = head;
	window_list_t *ptr        = *head;

	while (ptr->window->pid != pid) {
		prev_next = &ptr->next;
		ptr       = ptr->next;
		if (ptr == NULL)
			return NULL;
	}

	*prev_next = ptr->next;

	window_t *s = ptr->window;
	free(ptr);
	return s;
}

window_t *window_list_find_by_id(window_list_t **head, window_id_t id) {
	assert(head != NULL);
	window_list_t *ptr = *head;
	while (ptr != NULL && ptr->window->id != id)
		ptr = ptr->next;
	if (ptr == NULL)
		return NULL;
	return ptr->window;
}

window_t *window_list_find_by_pid(window_list_t **head, pid_t pid) {
	assert(head != NULL);
	window_list_t *ptr = *head;
	while (ptr != NULL && ptr->window->pid != pid)
		ptr = ptr->next;
	if (ptr == NULL)
		return NULL;
	return ptr->window;
}

void window_kill(window_t *w) {
	kill(w->pid, SIGTERM);
}

int window_start_master(window_t *s, int pty_master) {
	assert(s != NULL);
	assert(s->addr != NULL);
	if (s->master_handler == NULL) {
		s->master_handler = spub_master_handler;
	}
	return s->master_handler(s, pty_master);
}

int window_start_child(window_t *s) {
	assert(s != NULL);
	assert(s->command_args != NULL);
	assert(s->command_args[0] != NULL);
	assert(*s->command_args[0] != '\0');

	/* pipe used to handle errors in children */
	int pipefd[2];

	if (pipe(pipefd) == -1) {
		return -1;
	}

	int pty_master;
	pid_t cpid = forkpty(&pty_master, NULL, NULL, s->size);

	if (cpid < 0)
		return -1;

	if (cpid == 0) {
		assert(close(pipefd[0]) == 0);
		/* Use pipe closed to signal to parent a successful exec */
		/* we don't use "waitpid" since main thread is handling children*/
		assert(fcntl(pipefd[1], F_SETFD, FD_CLOEXEC) >= 0);

		sigset_t emptyset;
		sigemptyset(&emptyset);
		sigprocmask(SIG_SETMASK, &emptyset, NULL);
		pthread_sigmask(SIG_SETMASK, &emptyset, NULL);
		execvp(s->command_args[0], s->command_args);
		write(pipefd[1], &errno, sizeof(errno));
		close(pipefd[1]);
		exit(EXIT_FAILURE);
	}

	assert(close(pipefd[1]) == 0);
	int reterrno = 0;
	while (read(pipefd[0], &reterrno, sizeof(reterrno)) > 0) {
	}

	assert(close(pipefd[0]) == 0);

	if (reterrno != 0) {
		errno = reterrno;
		return -1;
	}

	s->pid = cpid;
	return pty_master;
}

char *window_state_str(window_t *w) {
	char buf[256];
	int status = w->status;

	if (w->pid != 0) {
		return strdup("running");
	}

	if (WIFEXITED(status)) {
		snprintf(buf, sizeof(buf), "exited(%d)", WEXITSTATUS(status));
	} else if (WIFSIGNALED(status)) {
		snprintf(buf, sizeof(buf), "killed(%d)", WTERMSIG(status));
	}

	return strdup(buf);
}

json_t *window_marshal_json(window_t *w) {
	char **ptr;
	if (w == NULL)
		return json_null();

	json_t *ret = json_pack("{s:i, s:i, s:i, s:s}", "id", w->id, "pid", w->pid,
	                        "scrollback_length", w->scrollback_len, "address", w->addr);

	if (w->command_args) {
		json_t *command_args = json_array();
		ptr                  = w->command_args;
		while (*ptr) {
			json_array_append_new(command_args, json_string(*ptr++));
		}
		json_object_set_new(ret, "command", command_args);
	}

	if (w->window_flags != NULL) {
		json_t *window_flags = json_array();
		ptr                  = w->window_flags;
		while (*ptr) {
			json_array_append_new(window_flags, json_string(*ptr++));
		}
		json_object_set_new(ret, "window_flags", window_flags);
	}

	if (w->pid != 0) {
		json_object_set_new(ret, "state", json_string("running"));
	} else if (WIFEXITED(w->status)) {
		json_object_set_new(ret, "state", json_string("exited"));
		json_object_set_new(ret, "exit_status", json_integer(WEXITSTATUS(w->status)));

	} else if (WIFSIGNALED(w->status)) {
		json_object_set_new(ret, "state", json_string("terminated"));
		json_object_set_new(ret, "terminate_signal", json_integer(WTERMSIG(w->status)));
	}

	return ret;
}

json_t *window_list_marshal_json(window_list_t **head) {
	json_t *ret = json_array();

	window_list_t *ptr = *head;
	while (ptr != NULL) {
		json_array_append_new(ret, window_marshal_json(ptr->window));
		ptr = ptr->next;
	}
	return ret;
}
