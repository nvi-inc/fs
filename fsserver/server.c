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

#include "server.h"
#include "window.h"

char const *fs_command[] = {"fs", "-i", NULL};

int msgprintf(nng_msg *msg, char *format, ...) {
	va_list args;
	char *buf;
	size_t sz;
	va_start(args, format);
	sz = vasprintf(&buf, format, args);
	va_end(args);
	if (sz < 0)
		return NNG_ENOMEM;
	if (nng_msg_append(msg, buf, sz) != 0)
		return NNG_ENOMEM;
	free(buf);
	return 0;
}

int json_object_sprintf(json_t *obj, const char *key, char *const format, ...) {
	va_list args;
	char *buf;
	size_t sz;
	va_start(args, format);
	sz = vasprintf(&buf, format, args);
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

	errno = 0;

	if (len > sizeof(_path) - 1) {
		errno = ENAMETOOLONG;
		return -1;
	}
	strcpy(_path, path);

	/* Iterate the string */
	for (p = _path + 1; *p; p++) {
		if (*p == '/') {
			/* Temporarily truncate */
			*p = '\0';

			if (mkdir(_path, S_IRWXU) != 0) {
				if (errno != EEXIST)
					return -1;
			}

			*p = '/';
		}
	}

	if (mkdir(_path, S_IRWXU) != 0) {
		if (errno != EEXIST)
			return -1;
	}

	return 0;
}

static char *addr_by_id(unsigned id) {
	char *s;

	/* TODO: handle this better */
	if (asprintf(&s, FS_SERVER_BASE_PATH "/windows/%d", id) < 0)
		return NULL;
	mkdir_p(s);
	free(s);

	if (asprintf(&s, "ipc://" FS_SERVER_BASE_PATH "/windows/%d", id) < 0)
		return NULL;
	return s;
}

static char *strjoin(int argc, const char *const argv[]) {
	if (argc <= 0) {
		return NULL;
	}

	size_t len = 0;
	for (int i = 0; i < argc; i++)
		len += strlen(argv[i]) + 1;

	char *s = malloc(len);

	char *to = s;
	const char *from;
	for (int i = 0; i < argc; i++) {
		from = argv[i];
		while (*from)
			*to++ = *from++;
		*to++ = ' ';
	}
	*--to = '\0';
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
 * Make a window command for the clients
 */
static nng_msg *window_cmd_msg(window_t *w) {
	const char windowstr[] = "window ";
	nng_msg *msg;
	int rv;
	rv = nng_msg_alloc(&msg, 0);
	if (rv < 0)
		return NULL;

	nng_msg_append(msg, windowstr, strlen(windowstr));
	nng_msg_append(msg, w->addr, strlen(w->addr));
	nng_msg_append(msg, "/pub", 4);
	nng_msg_append(msg, " ", 1);
	nng_msg_append(msg, w->addr, strlen(w->addr));
	nng_msg_append(msg, "/rep", 4);

	if (w->window_flags) {
		char **ptr = w->window_flags;
		while (*ptr) {
			nng_msg_append(msg, " ", 1);
			nng_msg_append(msg, *ptr, strlen(*ptr));
			ptr++;
		}
	}

	return msg;
}

struct server {
	bool running;
	nng_mtx *mtx;
	unsigned next_window_id;
	int finished_pipe[2];
	char *server_cmd_url;
	char *clients_cmd_url;
	nng_socket server_cmd_sock;
	nng_socket clients_cmd_sock;
	nng_aio *aio;
	window_t *fs;
	window_list_t *windows;
	bool prompt_open;
	char *prompt_msg;
};

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
	window_list_t *wl = s->windows;

	json_t *windows = window_list_marshal_json(&wl);
	json_object_set_new(rep_msg, "windows", windows);
	nng_mtx_unlock(s->mtx);
	return 0;
}

/*
 * server_cmd_window_new starts a new window with command given in args.
 * arguments are the same as xterms, including "-e" to specify the command.
 */
int server_cmd_window_new(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	int rv;
	window_t *w = NULL;
	if (argc <= 1) {
		json_object_sprintf(rep_msg, "message", "new window usage here");
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
	window_list_append(&s->windows, w);
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

	json_t *window_json = window_marshal_json(w);
	json_object_set_new(rep_msg, "window", window_json);

	nng_mtx_unlock(s->mtx);

	nng_msg *clients_msg = window_cmd_msg(w);
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
	window_t *w = window_list_pop_by_id(&s->windows, id);
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
		json_object_sprintf(rep_msg, "message", "window usage here");
		return 1;
	}

	if (strcmp(argv[1], "new") == 0) {
		return server_cmd_window_new(s, rep_msg, argc - 1, argv + 1);
	}

	if (strcmp(argv[1], "list") == 0) {
		return server_cmd_window_list(s, rep_msg, argc - 1, argv + 1);
	}

	if (strcmp(argv[1], "kill") == 0) {
		return server_cmd_window_kill(s, rep_msg, argc - 1, argv + 1);
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"%s\"", argv[0]);
	return 1;
};

int server_cmd_status_commands(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc > 1) {
		json_object_sprintf(rep_msg, "message",
		                    "unknown argument to status commands \"%s\"", argv[1]);
		return 1;
	}
	if (s->prompt_open) {
		json_object_sprintf(rep_msg, "message", "prompt open \"%s\"\n", s->prompt_msg);
	} else {
		json_object_sprintf(rep_msg, "message", "");
	}
	return 0;
}

int server_cmd_status(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc > 1 && strcmp("commands", argv[1]) == 0) {
		return server_cmd_status_commands(s, rep_msg, argc - 1, argv + 1);
	}
	nng_mtx_lock(s->mtx);
	json_t *status = json_object();
	json_object_set_new(status, "running", json_true());

	json_object_set_new(status, "fs_running", json_boolean(s->fs != NULL && s->fs->pid != 0));
	int nwindows = window_list_len(&s->windows);
	json_object_set_new(status, "nwinows", json_integer(nwindows));

	if (s->prompt_open) {
		json_object_set_new(rep_msg, "prompt", json_string(s->prompt_msg));
	}

	json_object_set_new(rep_msg, "status", status);
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

	s->prompt_open = false;

	s->fs = window_new();

	if (s->fs == NULL) {
		json_object_sprintf(rep_msg, "message", "error starting fs: %s", strerror(ENOMEM));
		goto error;
	}

	/* TODO: make these settings configurable */
	mkdir_p(FS_SERVER_BASE_PATH "/windows/fs");
	s->fs->command_args   = strandup(3, fs_command);
	s->fs->addr           = strdup("ipc://" FS_SERVER_BASE_PATH "/windows/fs");
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
		json_object_set_new(rep_msg, "message", json_string("usage: fs [start|status]"));
		return 1;
	}

	if (strcmp(argv[1], "start") == 0) {
		return server_cmd_fs_start(s, rep_msg, argc - 1, argv + 1);
	}
	if (strcmp(argv[1], "status") == 0) {
		return server_cmd_fs_status(s, rep_msg, argc - 1, argv + 1);
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"%s\"", argv[1]);
	return 1;
}

int server_cmd_prompt(server_t *s, json_t *rep_msg, int argc, const char *const argv[]) {
	if (argc <= 1) {
		json_object_sprintf(rep_msg, "message", "usage: prompt [open msg|close]", argv[0]);
	}
	int rv;

	if (strcmp(argv[1], "open") == 0) {
		nng_mtx_lock(s->mtx);

		if (s->prompt_open) {
			json_object_sprintf(rep_msg, "message", "prompt already open");
			nng_mtx_unlock(s->mtx);
			return 1;
		}

		if (s->fs == NULL || s->fs->pid == 0) {
			json_object_sprintf(rep_msg, "message", "fs not running");
			nng_mtx_unlock(s->mtx);
			return 1;
		}

		if (s->prompt_msg != NULL) {
			free(s->prompt_msg);
			s->prompt_msg = NULL;
		}
		s->prompt_msg  = strjoin(argc - 2, argv + 2);
		s->prompt_open = true;
		system("inject_snap halt");

		nng_msg *msg;
		rv = nng_msg_alloc(&msg, 0);
		if (rv != 0) {
			json_object_sprintf(rep_msg, "message", "error allocating new msg: %s",
			                    nng_strerror(rv));
			nng_mtx_unlock(s->mtx);
			return 1;
		}
		msgprintf(msg, "prompt open \"%s\"", s->prompt_msg);
		rv = nng_sendmsg(s->clients_cmd_sock, msg, 0);
		if (rv != 0) {
			json_object_sprintf(rep_msg, "message",
			                    "error sending message to clients: %s",
			                    nng_strerror(rv));
			nng_mtx_unlock(s->mtx);
			return 1;
		}
		nng_mtx_unlock(s->mtx);

		return 0;
	}

	if (strcmp(argv[1], "close") == 0) {
		nng_mtx_lock(s->mtx);
		if (!s->prompt_open) {
			json_object_sprintf(rep_msg, "message", "prompt not running");
			nng_mtx_unlock(s->mtx);
			return 1;
		}
		if (s->prompt_msg != NULL) {
			free(s->prompt_msg);
			s->prompt_msg = NULL;
		}
		s->prompt_open = false;
		system("inject_snap cont");

		nng_msg *msg;
		rv = nng_msg_alloc(&msg, 0);
		if (rv != 0) {
			json_object_sprintf(rep_msg, "message", "error allocating new msg: %s",
			                    nng_strerror(rv));
			nng_mtx_unlock(s->mtx);
			return 1;
		}

		msgprintf(msg, "prompt close");
		rv = nng_sendmsg(s->clients_cmd_sock, msg, 0);
		if (rv != 0) {
			json_object_sprintf(rep_msg, "message",
			                    "error sending message to clients: %s",
			                    nng_strerror(rv));
			nng_mtx_unlock(s->mtx);
			return 1;
		}
		nng_mtx_unlock(s->mtx);
		return 0;
	}

	json_object_sprintf(rep_msg, "message", "unknown command \"prompt %s\"", argv[1]);
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
	return 1;
}

void server_cmd_cb(void *arg) {
	nng_msg *msg, *reply_msg;
	server_t *s = arg;
	int cmd_rv;
	int rv;

	assert(s != NULL);

	if (nng_aio_result(s->aio) != 0)
		return;

	msg = nng_aio_get_msg(s->aio);

	char *body = nng_msg_body(msg);

	if (body[nng_msg_len(msg)] != '\0') {
		nng_msg_append(msg, "\0", 1);
		body = nng_msg_body(msg);
	}

	rv = nng_msg_alloc(&reply_msg, 0);
	if (rv != 0) {
		exit(1);
	}

	json_error_t err;
	json_t *method    = NULL;
	json_t *params    = NULL;
	json_t *json      = NULL;
	json_t *value     = NULL;
	json_t *error     = NULL;
	char const **args = NULL;
	char const **pos;

	json = json_loads(body, 0, &err);
	if (!json_is_object(json)) {
		printf("TODO: error decoding\n");
		goto end;
	}

	method = json_object_get(json, "method");
	if (!json_is_string(method)) {
		error = json_string("method is not a string");
		goto error;
	}
	params = json_object_get(json, "params");

	if (!json_is_array(params)) {
		error = json_string("params is not an array");
		goto error;
	}

	char *params_str = json_dumps(params, 0);
	free(params_str);

	args = calloc(json_array_size(params) + 2, sizeof(char *));

	pos = args;

	*pos++ = json_string_value(method);

	size_t index;
	json_array_foreach(params, index, value) {
		if (!json_is_string(value)) {
			error = json_string("non string found in params array");
			goto error;
		}
		*pos++ = json_string_value(value);
	}

	json_t *reply = json_object();

	json_t *ret = json_object();
	cmd_rv      = server_cmd(s, ret, json_array_size(params) + 1, args);

	if (cmd_rv > 0) {
		json_object_set_new(reply, "error", ret);
	} else {
		json_object_set_new(reply, "result", ret);
	}

	char *reply_str = json_dumps(reply, 0);
	nng_msg_append(reply_msg, reply_str, strlen(reply_str));
	free(reply_str);
	json_decref(reply);

	rv = nng_sendmsg(s->server_cmd_sock, reply_msg, 0);
	if (rv != 0) {
		nng_msg_free(reply_msg);
		return;
	}

end:
	json_decref(json);
	nng_msg_free(msg);
	free(args);
	nng_recv_aio(s->server_cmd_sock, s->aio);
	return;

error:
	reply = json_object();
	json_object_set_new(reply, "error", error);
	reply_str = json_dumps(reply, 0);
	nng_msg_append(reply_msg, reply_str, strlen(reply_str));
	free(reply_str);
	json_decref(reply);
	rv = nng_sendmsg(s->server_cmd_sock, reply_msg, 0);
	if (rv != 0) {
		nng_msg_free(reply_msg);
	}
	goto end;
}

void server_sigchld_cb(server_t *s, pid_t pid, int status) {
	nng_mtx_lock(s->mtx);
	if (s->fs != NULL && pid == s->fs->pid) {
		s->fs->status  = status;
		s->fs->pid     = 0;
		s->prompt_open = false;

		nng_mtx_unlock(s->mtx);
		return;
	}
	window_t *w = window_list_find_by_pid(&s->windows, pid);
	if (w == NULL) {
		nng_mtx_unlock(s->mtx);
		return;
	}
	w->status = status;
	w->pid    = 0;

	nng_mtx_unlock(s->mtx);
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

	s->server_cmd_url   = strdup("ipc://" FS_SERVER_BASE_PATH "/cmd");
	s->clients_cmd_url  = strdup("ipc://" FS_SERVER_BASE_PATH "/clicmd");
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
	while ((w = window_list_pop(&s->windows)) != NULL) {
		window_kill(w);
		window_free(w);
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
