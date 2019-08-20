#include <stdbool.h>
#include <stdlib.h>

#include <jansson.h>

typedef long window_id_t;

/* Linked list of windows*/
typedef struct window {
	window_id_t id;
	pid_t pid;  // < 0 if terminated
	int status; // status returned by wait, use wait macros to access
	char **command_args;
	struct winsize *size;
	char **window_flags;
	int scrollback_len;
	char *addr;
	int (*master_handler)(struct window *, int);
} window_t;

bool window_by_pid(void *, void *);
bool window_by_id(void *, void *);

json_t *window_marshal_json(window_t *w);
int window_unmarshal_json(window_t *w, json_t *j);

window_t *window_new();
void window_kill(window_t *s);
void window_free(window_t *s);
char *window_state_str(window_t *s);

/*
 * window_start_child starts child process and updates the pid of the window.
 *
 * returns the master end of the pty, or -1 on error.
 */
int window_start_child(window_t *s);

/*
 * window_start_master starts the master pty handler of the window, given
 * the master pty file descriptor. The default spub based handler is
 * used if master_handler == NULL.
 *
 * returns -1 on error.
 */
int window_start_master(window_t *s, int pty_master);
