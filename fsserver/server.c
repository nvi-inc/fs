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
#define _GNU_SOURCE
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <wordexp.h>

#include <nng/nng.h>
#include <nng/protocol/pubsub0/pub.h>
#include <nng/protocol/reqrep0/rep.h>
#include <nng/protocol/reqrep0/req.h>
#include <nng/supplemental/util/platform.h>

#include <jansson.h>

#include "../include/params.h"
#include "list.h"
#include "prompt.h"
#include "server.h"
#include "window.h"

enum { JSONRCP_STATUS_PARSE_ERROR      = -32700,
       JSONRCP_STATUS_INVALID_REQUEST  = -32600,
       JSONRCP_STATUS_METHOD_NOT_FOUND = -32601,
       JSONRCP_STATUS_INVALID_PARAMS   = -32702,
       JSONRCP_STATUS_INTERNAL_ERROR   = -32703,
};

struct server {
	nng_mtx *mtx;
	bool running;
	int finished_pipe[2];

	nng_aio *aio;

	char *server_cmd_url;
	char *clients_cmd_url;
	nng_socket server_cmd_sock;
	nng_socket clients_cmd_sock;

	unsigned next_window_id;
	list_t *windows;
	window_t *fs;

	unsigned next_prompt_id;
	list_t *prompts;
};

char const *fs_command[] = {"fs", "-i", NULL};

int json_object_sprintf(json_t *obj, const char *key, char *const format, ...) {
	va_list args;
	char *buf;
	va_start(args, format);
	int sz = vasprintf(&buf, format, args);
	if (sz < 0)
		return NNG_ENOMEM;
	va_end(args);
	json_t *jstr = json_string(buf);
	json_object_set_new(obj, key, jstr);
	free(buf);
	return 0;
}

static int mkdir_p(char *const path) {
	/* Adapted from http://stackoverflow.com/a/2336245/119527 */
	const size_t len = strlen(path);
	char _path[PATH_MAX];
	char *p;

	if (len > sizeof(_path) - 1) {
		errno = ENAMETOOLONG;
		return -1;
	}

	strcpy(_path, path);

	for (p = _path + 1; *p; p++) {
		if (*p == '/') {
			*p = '\0';
			if (mkdir(_path, S_IRWXU | S_IRWXG | S_IRWXO) != 0)
				if (errno != EEXIST)
					return -1;
			*p = '/';
		}
	}

	if (mkdir(_path, S_IRWXU | S_IRWXG | S_IRWXO) != 0)
		if (errno != EEXIST)
			return -1;

	return 0;
}

static char *addr_by_id(unsigned id) {
	char *s;

#ifdef FS_SERVER_SOCKET_PATH
	if (asprintf(&s, FS_SERVER_SOCKET_PATH "/windows/%d", id) < 0)
		return NULL;
	mkdir_p(s);
	free(s);
#endif

	if (asprintf(&s, FS_SERVER_URL_BASE "/windows/%d", id) < 0)
		return NULL;
	return s;
}

static char **strandup(size_t len, const char *const *const argv) {
	char **ret = calloc(len + 1, sizeof(char *));
	char **to  = ret;

	const char *const *from = argv;
	size_t n                = 0;
	while (n < len && *from) {
		*to++ = strdup(*from++);
		n++;
	}
	return ret;
}

static int args_split(int argc, const char *const argv[], char *seperator, char ***left,
                      char ***right) {
	int sep_pos = 0;

	while (sep_pos < argc) {
		if (strcmp(argv[sep_pos], seperator) == 0) {
			break;
		}
		sep_pos++;
	}

	if (sep_pos >= argc) {
		return -1;
	}

	*left  = strandup(sep_pos, argv);
	*right = strandup(argc - sep_pos - 1, argv + sep_pos + 1);
	return 0;
}

static void parse_xargs_to_winsz(char *const xargs[], struct winsize **size) {
	struct winsize *wsz = NULL;
	char *buf;

	if (xargs == NULL) {
		*size = NULL;
		return;
	}

	char *const *ptr = xargs;
	while (*ptr) {
		if (strcmp("-geometry", *ptr++) == 0) {
			break;
		}
	}

	if (!*ptr) {
		*size = NULL;
		return;
	}

	buf = strdup(*ptr);
	if (buf == NULL) {
		*size = NULL;
		return;
	}

	char *p = strtok(buf, "+- \t");

	/* does the string contain an x?*/
	for (char *p2 = p; *p2 != 'x'; p2++) {
		if (*p2 == '\0')
			goto cleanup;
	}

	p = strtok(p, "x");

	wsz = calloc(sizeof(struct winsize), 1);

	if (!wsz) {
		goto cleanup;
	}

	long l;
	l     = 0;
	errno = 0;
	l     = strtol(p, NULL, 10);

	if (errno != 0 && l == 0)
		goto cleanup;

	if (l <= 0)
		goto cleanup;

	if (l > SHRT_MAX)
		goto cleanup;

	wsz->ws_col = l;

	p = strtok(NULL, "x");
	if (p == NULL) {
		goto cleanup;
	}
	l     = 0;
	errno = 0;
	l     = strtol(p, NULL, 10);
	if (errno != 0 && l == 0)
		goto cleanup;

	if (l <= 0)
		goto cleanup;

	if (l > SHRT_MAX)
		goto cleanup;

	wsz->ws_row = l;

	*size = wsz;
	free(buf);
	return;

cleanup:
	free(buf);
	free(wsz);
	*size = NULL;
	return;
}

/*
 * prompt_open_msg creates an nng_msg containing the json rpc client call
 * for opening prompt p.
 */

nng_msg *json_dumpmsg(json_t *j) {
	size_t size = json_dumpb(j, NULL, 0, 0);
	if (size == 0)
		return NULL;
	nng_msg *msg;
	int rv = nng_msg_alloc(&msg, size);
	if (rv != 0) {
		fprintf(stderr, "unable to allocate a new message\n");
		exit(EXIT_FAILURE);
	}
	json_dumpb(j, nng_msg_body(msg), size, 0);
	return msg;
}

static nng_msg *prompt_open_msg(prompt_t *p) {
	json_t *j = json_object();
	json_object_set_new(j, "jsonrpc", json_string("2.0"));
	json_object_set_new(j, "method", json_string("prompt_open"));
	json_object_set_new(j, "params", prompt_marshal_json(p));
	nng_msg *msg = json_dumpmsg(j);
	json_decref(j);
	return msg;
}

/*
 * prompt_close_msg creates an nng_msg containing the json rpc client call
 * for closing prompt p.
 */
static nng_msg *prompt_close_msg(prompt_t *p) {
	json_t *j = json_object();
	json_object_set_new(j, "jsonrpc", json_string("2.0"));
	json_object_set_new(j, "method", json_string("prompt_close"));
	json_object_set_new(j, "params", prompt_marshal_json(p));
	nng_msg *msg = json_dumpmsg(j);
	json_decref(j);
	return msg;
}

/*
 * window_cmd_msg generates a nng allocated buffer conisting of the client command to open window w.
 */
static nng_msg *window_open_msg(window_t *w) {
	json_t *j = json_object();
	json_object_set_new(j, "jsonrpc", json_string("2.0"));
	json_object_set_new(j, "method", json_string("window_open"));
	json_object_set_new(j, "params", window_marshal_json(w));
	nng_msg *msg = json_dumpmsg(j);
	json_decref(j);
	return msg;
}

/*
 * server_finished_fd returns a file descriptor that will be closed
 * when the server goes into shutdown.
 */
int server_finished_fd(server_t *s) {
	nng_mtx_lock(s->mtx);
	if (s->finished_pipe[1] == -1 && pipe(s->finished_pipe) < 0) {
		s->finished_pipe[0] = -1;
		s->finished_pipe[1] = -1;
		return -1;
	}
	fcntl(s->finished_pipe[0], F_SETFD, FD_CLOEXEC);
	int r = s->finished_pipe[1];
	nng_mtx_unlock(s->mtx);
	return r;
}

int server_cmd_shutdown(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc > 1) {
		json_object_sprintf(rep_msg, "message", "unknown argument to shutdown \"%s\"",
		                    argv[1]);
		return 1;
	}

	server_shutdown(s);
	return 0;
}

int server_cmd_window_list(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc > 1) {
		json_object_sprintf(rep_msg, "message", "unknown argument to list \"%s\"", argv[1]);
		return 1;
	}

	nng_mtx_lock(s->mtx);
	json_t *windows = json_array();
	list_t *ptr     = s->windows;
	while (ptr != NULL) {
		json_array_append_new(windows, window_marshal_json((window_t *)ptr->data));
		ptr = ptr->next;
	}
	json_object_set_new(rep_msg, "windows", windows);
	nng_mtx_unlock(s->mtx);
	return 0;
}

/*
 * server_cmd_window_open starts a new window with command given in args. Arguments before "-e" are
 * passed to the clients unmodified, arguments after "-e" specify the command to start in the
 * window. This allows xterm arguments can be passed to the clients.
 */
int server_cmd_window_open(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	int rv;
	window_t *w = NULL;

	if (argc <= 1) {
		json_object_sprintf(rep_msg, "message", "usage: window new [args...] -e cmd");
		return 1;
	}

	w = window_new();

	rv = args_split(argc - 1, argv + 1, "-e", &w->window_flags, &w->command_args);
	if (rv < 0 || w->command_args == NULL) {
		json_object_sprintf(
		    rep_msg, "message",
		    "error: no command specified, must be provided after '-e' flag");
		goto error;
	}

	parse_xargs_to_winsz(w->window_flags, &w->size);

	nng_mtx_lock(s->mtx);
	w->id = s->next_window_id++;
	list_append(&s->windows, w);
	/* TODO handle EOM here */

	w->addr           = addr_by_id(w->id);
	w->scrollback_len = 1000;

	int pty = window_start_child(w);
	if (pty < 0) {
		json_object_sprintf(rep_msg, "message", "error starting window: %s",
		                    strerror(errno));
		nng_mtx_unlock(s->mtx);
		goto error;
	}

	if (window_start_master(w, pty) < 0) {
		json_object_sprintf(rep_msg, "message", "error starting window handler: %s",
		                    strerror(errno));
		nng_mtx_unlock(s->mtx);
		goto error;
	}

	json_object_set_new(rep_msg, "window", window_marshal_json(w));
	nng_mtx_unlock(s->mtx);

	nng_msg *clients_msg = window_open_msg(w);
	if (clients_msg == NULL)
		goto error;

	rv = nng_sendmsg(s->clients_cmd_sock, clients_msg, 0);
	if (rv < 0) {
		nng_msg_free(clients_msg);
		json_object_sprintf(rep_msg, "message", "error sending message to clients: %s",
		                    nng_strerror(rv));
		goto error;
	}

	return 0;
error:
	if (w != NULL) {
		window_free(w);
	}
	return 1;
}

int server_cmd_window_kill(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc < 2) {
		json_object_sprintf(rep_msg, "message", "kill requires an argument");
		return 1;
	}

	char *end;

	window_id_t id = 0;
	errno          = 0;

	id = strtol(argv[1], &end, 10);
	if ((errno == ERANGE && (id == LONG_MAX || id == LONG_MIN)) || (errno != 0 && id == 0)) {
		json_object_sprintf(rep_msg, "message", "argument to kill is not an integer");
		return 1;
	}

	nng_mtx_lock(s->mtx);
	window_t *w = list_pop(&s->windows, window_by_id, &id);
	nng_mtx_unlock(s->mtx);
	if (w == NULL) {
		json_object_sprintf(rep_msg, "message", "window %li is not running", id);
		return 1;
	}

	if (w->pid != 0)
		window_kill(w);
	window_free(w);
	return 0;
}

int server_cmd_window(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc <= 1) {
		json_object_sprintf(rep_msg, "message", "window new|list|kill");
		return 1;
	}

	if (strcmp(argv[1], "open") == 0) {
		return server_cmd_window_open(s, rep_msg, argc - 1, argv + 1);
	}

	if (strcmp(argv[1], "list") == 0) {
		return server_cmd_window_list(s, rep_msg, argc - 1, argv + 1);
	}

	if (strcmp(argv[1], "kill") == 0) {
		return server_cmd_window_kill(s, rep_msg, argc - 1, argv + 1);
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"window %s\"", argv[1]);
	json_object_set_new(rep_msg, "code", json_integer(JSONRCP_STATUS_METHOD_NOT_FOUND));
	return 1;
};

int server_cmd_status(server_t *s, json_t *rep, int argc, const char *const argv[]) {
	if (argc > 1 && strcmp("commands", argv[1]) == 0) {
		// return server_cmd_status_commands(s, rep_msg, argc - 1, argv + 1);
		return 1;
	}
	nng_mtx_lock(s->mtx);

	json_object_set_new(rep, "fs_running", json_boolean(s->fs != NULL && s->fs->pid != 0));

	json_t *prompts = json_array();
	prompt_t *prompt;
	list_t *l = s->prompts;
	while (l != NULL) {
		prompt = l->data;
		json_array_append_new(prompts, prompt_marshal_json(prompt));
		l = l->next;
	}
	json_object_set_new(rep, "prompts", prompts);

	json_t *windows = json_array();
	window_t *window;
	l = s->windows;
	while (l != NULL) {
		window = l->data;
		json_array_append_new(windows, window_marshal_json(window));
		l = l->next;
	}
	json_object_set_new(rep, "windows", windows);

	nng_mtx_unlock(s->mtx);
	return 0;
}

int server_cmd_fs_start(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc > 1) {
		json_object_sprintf(rep_msg, "message", "unknown argument to fs start \"%s\"",
		                    argv[1]);
		return 1;
	}

	nng_mtx_lock(s->mtx);

	if (s->fs != NULL) {
		if (s->fs->pid != 0) {
			json_object_sprintf(rep_msg, "message", "%s",
			                    "field system already running");
			nng_mtx_unlock(s->mtx);
			return 1;
		}
		/* TODO: could reuse structure (and even buffer if we merge spub into server) */
		window_free(s->fs);
	}

	s->fs = window_new();

	if (s->fs == NULL) {
		json_object_sprintf(rep_msg, "message", "error starting fs: %s", strerror(ENOMEM));
		goto error;
	}

#ifdef FS_SERVER_SOCKET_PATH
	mkdir_p(FS_SERVER_SOCKET_PATH "/windows/fs");
#endif
	s->fs->command_args   = strandup(3, fs_command);
	s->fs->addr           = strdup(FS_SERVER_URL_BASE "/windows/fs");
	s->fs->scrollback_len = 3000;

	int pty = window_start_child(s->fs);
	if (pty < 0) {
		json_object_sprintf(rep_msg, "message", "error starting fs: %s", strerror(errno));
		goto error;
	}

	if (window_start_master(s->fs, pty) < 0) {
		json_object_sprintf(rep_msg, "message", "error starting fs: %s", strerror(errno));
		goto error;
	}
	nng_mtx_unlock(s->mtx);
	return 0;

error:
	window_free(s->fs);
	s->fs = NULL;
	nng_mtx_unlock(s->mtx);
	return 1;
}

int server_cmd_fs_status(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc > 1) {
		json_object_sprintf(rep_msg, "message", "unknown command \"%s\"", argv[1]);
		return 1;
	}
	nng_mtx_lock(s->mtx);
	if (s->fs == NULL || s->fs->pid == 0) {
		nng_mtx_unlock(s->mtx);
		return 1;
	}
	nng_mtx_unlock(s->mtx);
	return 0;
}

int server_cmd_fs(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc <= 1) {
		/* TODO: usage */
		json_object_set_new(rep_msg, "message", json_string("usage: fs start|status"));
		return 1;
	}

	if (strcmp(argv[1], "start") == 0) {
		return server_cmd_fs_start(s, rep_msg, argc - 1, argv + 1);
	}
	if (strcmp(argv[1], "status") == 0) {
		return server_cmd_fs_status(s, rep_msg, argc - 1, argv + 1);
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"%s\"", argv[1]);
	json_object_set_new(rep_msg, "code", json_integer(JSONRCP_STATUS_METHOD_NOT_FOUND));
	return 1;
}

int server_cmd_prompt(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc <= 1) {
		json_object_sprintf(rep_msg, "message",
		                    "usage:\n\tprompt open msg\n\tprompt close]", argv[0]);
	}
	int rv;

	if (strcmp(argv[1], "open") == 0) {
		if (argc < 3) {
			json_object_set_new(rep_msg, "message",
			                    json_string("prompt requires a message"));
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INVALID_PARAMS));
			return 1;
		}

		prompt_t *p = prompt_new();
		p->message  = strdup(argv[2]);

		nng_mtx_lock(s->mtx);
		p->id = s->next_prompt_id++;
		nng_mtx_unlock(s->mtx);

		if (argc > 3) {
			p->cont = (*argv[3] == '1');
		}

		nng_msg *msg = prompt_open_msg(p);
		if (!msg) {
			json_object_sprintf(rep_msg, "message", "error allocating new msg");
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INTERNAL_ERROR));
			nng_mtx_unlock(s->mtx);
			return 1;
		}

		rv = nng_sendmsg(s->clients_cmd_sock, msg, 0);
		if (rv != 0) {
			json_object_sprintf(rep_msg, "message",
			                    "error sending message to clients: %s",
			                    nng_strerror(rv));
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INTERNAL_ERROR));
			nng_mtx_unlock(s->mtx);
			return 1;
		}

		nng_mtx_lock(s->mtx);
		list_append(&s->prompts, p);
		nng_mtx_unlock(s->mtx);

		json_object_set_new(rep_msg, "prompt", prompt_marshal_json(p));
		return 0;
	}

	if (strcmp(argv[1], "close") == 0) {
		if (argc < 3) {
			json_object_set_new(rep_msg, "message",
			                    json_string("close requires a prompt id"));
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INVALID_PARAMS));
			return 1;
		}

		char *end;
		unsigned id = strtoul(argv[2], &end, 0);
		// if end is not '\0', there is trailing character so return an error
		if (!*argv[2] || *end) {
			json_object_sprintf(rep_msg, "message", "invalid prompt id \"%s\"",
			                    argv[2]);
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INVALID_PARAMS));
			return 1;
		}

		nng_mtx_lock(s->mtx);
		prompt_t *p = list_pop(&s->prompts, prompt_by_id, &id);
		nng_mtx_unlock(s->mtx);

		if (!p) {
			json_object_sprintf(rep_msg, "message", "prompt with id \"%s\" not open",
			                    argv[2]);
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INVALID_PARAMS));
			return 1;
		}

		if (p->cont) {
			system("inject_snap cont");
		}

		json_object_set_new(rep_msg, "prompt", prompt_marshal_json(p));

		nng_msg *msg = prompt_close_msg(p);
		if (!msg) {
			/* this probably should be fatal since it means OOM*/
			json_object_sprintf(rep_msg, "message", "error allocating msg to clients");
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INTERNAL_ERROR));
			return 1;
		}

		rv = nng_sendmsg(s->clients_cmd_sock, msg, 0);
		if (rv != 0) {
			json_object_sprintf(rep_msg, "message",
			                    "error sending message to clients: %s",
			                    nng_strerror(rv));
			json_object_set_new(rep_msg, "code",
			                    json_integer(JSONRCP_STATUS_INTERNAL_ERROR));
			return 1;
		}

		prompt_free(p);
		return 0;
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"prompt %s\"", argv[1]);
	json_object_set_new(rep_msg, "code", json_integer(JSONRCP_STATUS_METHOD_NOT_FOUND));
	return 1;
}

int server_cmd(server_t *s, json_t *rep_msg, int argc, const char **const argv) {
	if (argc < 1) {
		const char usage[] = "status|window|shutodnw|fs";
		json_object_sprintf(rep_msg, "message", "usage: %s", usage);
		return 0;
	}

	if (strcmp(argv[0], "prompt") == 0) {
		return server_cmd_prompt(s, rep_msg, argc, argv);
	}

	if (strcmp(argv[0], "status") == 0) {
		return server_cmd_status(s, rep_msg, argc, argv);
	}

	if (strcmp(argv[0], "window") == 0) {
		return server_cmd_window(s, rep_msg, argc, argv);
	}

	if (strcmp(argv[0], "shutdown") == 0) {
		return server_cmd_shutdown(s, rep_msg, argc, argv);
	}

	if (strcmp(argv[0], "fs") == 0) {
		return server_cmd_fs(s, rep_msg, argc, argv);
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"%s\"", argv[0]);
	json_object_set_new(rep_msg, "code", json_integer(JSONRCP_STATUS_METHOD_NOT_FOUND));
	return 1;
}

void server_cmd_cb(void *arg) {
	char const **args = NULL;
	nng_msg *msg, *reply_msg;
	server_t *s = arg;
	int cmd_rv;
	int rv;

	assert(s != NULL);

	if (nng_aio_result(s->aio) != 0)
		return;

	msg = nng_aio_get_msg(s->aio);

	rv = nng_msg_alloc(&reply_msg, 0);
	if (rv != 0) {
		exit(1);
	}

	json_t *method  = NULL;
	json_t *params  = NULL;
	json_t *request = NULL;
	json_t *value   = NULL;
	json_t *error   = NULL;

	json_t *reply = json_object();
	json_object_set_new(reply, "jsonrpc", json_string("2.0"));
	json_object_set_new(request, "id", json_null());

	json_error_t err;
	request = json_loadb(nng_msg_body(msg), nng_msg_len(msg), 0, &err);
	nng_msg_free(msg);

	if (!request) {
		error = json_object();
		json_object_set_new(error, "message", json_string(err.text));
		json_object_set_new(error, "code", json_integer(JSONRCP_STATUS_PARSE_ERROR));
		goto error;
	}

	if (!json_is_object(request)) {
		/* TODO: check err */
		/* TODO: handled batch requets */
		error = json_object();
		json_object_set_new(error, "message", json_string("request must be an object"));
		json_object_set_new(error, "code", json_integer(JSONRCP_STATUS_INVALID_REQUEST));
		goto error;
	}

	json_t *id = json_object_get(request, "id");
	if (!id || json_is_null(id)) {
		error = json_object();
		json_object_set_new(error, "message",
		                    json_string("Invalid Request: id not speficied"));
		json_object_set_new(error, "code", json_integer(JSONRCP_STATUS_INVALID_REQUEST));
		goto error;
	}

	method = json_object_get(request, "method");
	if (!json_is_string(method)) {
		error = json_object();
		json_object_set_new(error, "message",
		                    json_string("Invalid Request: method not a string"));
		json_object_set_new(error, "code", json_integer(JSONRCP_STATUS_INVALID_REQUEST));
		goto error;
	}

	params = json_object_get(request, "params");
	if (!json_is_array(params)) {
		error = json_object();
		json_object_set_new(error, "message",
		                    json_string("Invalid Request: params not an array"));
		json_object_set_new(error, "code", json_integer(JSONRCP_STATUS_INVALID_REQUEST));
		goto error;
	}

	args    = calloc(json_array_size(params) + 2, sizeof(char *));
	args[0] = json_string_value(method);

	size_t index;
	json_array_foreach(params, index, value) {
		if (!json_is_string(value)) {
			error = json_string("non string found in params array");
			goto error;
		}
		args[index + 1] = json_string_value(value);
	}

	json_t *ret = json_object();
	cmd_rv      = server_cmd(s, ret, json_array_size(params) + 1, args);
	free(args);

	if (cmd_rv > 0) {
		json_object_set_new(reply, "error", ret);
	} else {
		json_object_set_new(reply, "result", ret);
	}

	char *reply_str = json_dumps(reply, 0);

end:
	nng_msg_append(reply_msg, reply_str, strlen(reply_str));
	free(reply_str);
	json_decref(reply);
	rv = nng_sendmsg(s->server_cmd_sock, reply_msg, 0);
	if (rv != 0) {
		nng_msg_free(reply_msg);
		/* TODO: we should report an error here*/
		return;
	}

	json_decref(request);
	nng_recv_aio(s->server_cmd_sock, s->aio);
	return;

error:
	json_object_set_new(reply, "error", error);
	reply_str = json_dumps(reply, 0);
	goto end;
}

void server_sigchld_cb(server_t *s, pid_t pid, int status) {
	nng_mtx_lock(s->mtx);
	if (s->fs != NULL && pid == s->fs->pid) {
		s->fs->status = status;
		s->fs->pid    = 0;
		nng_mtx_unlock(s->mtx);
		server_shutdown(s);
		return;
	}
	window_t *w = list_pop(&s->windows, window_by_pid, &pid);
	nng_mtx_unlock(s->mtx);
	if (w == NULL) {
		return;
	}
	w->status = status;
    /* TODO: could broadcast this to clients. */
	window_free(w);
	return;
}

void server_sigterm_cb(server_t *s) {
	server_shutdown(s);
}

bool server_is_running(server_t *s) {
	bool r;
	nng_mtx_lock(s->mtx);
	r = s->running;
	nng_mtx_unlock(s->mtx);
	return r;
}

int server_start(server_t *s) {
	int rv;
	assert(s != NULL);
	assert(s->server_cmd_url != NULL);
	assert(s->clients_cmd_url != NULL);

	nng_mtx_lock(s->mtx);

	rv = nng_listen(s->server_cmd_sock, s->server_cmd_url, NULL, 0);
	if (rv != 0) {
		goto error;
	}

	rv = nng_listen(s->clients_cmd_sock, s->clients_cmd_url, NULL, 0);
	if (rv != 0) {
		goto error;
	}

	rv = nng_aio_alloc(&s->aio, server_cmd_cb, s);
	if (rv != 0) {
		goto error;
	}

	s->running = true;
	nng_recv_aio(s->server_cmd_sock, s->aio);

	nng_mtx_unlock(s->mtx);
	return 0;

error:
	nng_mtx_unlock(s->mtx);
	return rv;
}

int server_new(server_t **new) {
	int rv;
	server_t *s = calloc(sizeof(server_t), 1);
	if (s == NULL) {
		return ENOMEM;
	}

	s->server_cmd_url   = strdup(FS_SERVER_URL_BASE "/cmd");
	s->clients_cmd_url  = strdup(FS_SERVER_URL_BASE "/clicmd");
	s->running          = false;
	s->finished_pipe[0] = -1;
	s->finished_pipe[1] = -1;

	rv = nng_rep0_open(&s->server_cmd_sock);
	if (rv != 0) {
		goto error;
	}
	rv = nng_pub0_open(&s->clients_cmd_sock);
	if (rv != 0) {
		goto error;
	}
	rv = nng_mtx_alloc(&s->mtx);
	if (rv != 0) {
		goto error;
	}
	*new = s;
	return 0;

error:
	nng_close(s->clients_cmd_sock);
	nng_close(s->server_cmd_sock);
	free(s);
	nng_mtx_free(s->mtx);
	return rv;
}

void server_shutdown(server_t *s) {
	nng_mtx_lock(s->mtx);
	s->running = false;
	if (s->finished_pipe[0] != -1) {
		close(s->finished_pipe[0]);
		s->finished_pipe[0] = -1;
		s->finished_pipe[1] = -1;
	}
	nng_mtx_unlock(s->mtx);
}

void server_destroy(server_t *s) {
	/* order is very important here! */
	nng_aio_free(s->aio);
	nng_close(s->server_cmd_sock);
	nng_close(s->clients_cmd_sock);

	nng_mtx_lock(s->mtx);
	window_t *w;
	while ((w = list_pop(&s->windows, NULL, NULL)) != NULL) {
		window_kill(w);
		window_free(w);
	}

	prompt_t *p;
	while ((p = list_pop(&s->prompts, NULL, NULL)) != NULL) {
		prompt_free(p);
	}

	/* TODO maybe send terminate to fs */
	if (s->fs != NULL) {
		window_kill(s->fs);
		window_free(s->fs);
	}

	nng_mtx_unlock(s->mtx);
	nng_mtx_free(s->mtx);
	free(s->clients_cmd_url);
	free(s->server_cmd_url);
	free(s);
}
