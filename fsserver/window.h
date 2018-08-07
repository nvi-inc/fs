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

typedef struct window_list {
	window_t *window;
	struct window_list *next;
} window_list_t;

/* caller is owner or returned value and must free*/
void window_list_append(window_list_t **head, window_t *new);
window_t *window_list_pop(window_list_t **head);
window_t *window_list_pop_by_id(window_list_t **head, window_id_t id);
window_t *window_list_pop_by_pid(window_list_t **head, pid_t pid);
window_t *window_list_find_by_id(window_list_t **head, window_id_t id);
window_t *window_list_find_by_pid(window_list_t **head, pid_t pid);
size_t window_list_len(window_list_t **head);

json_t *window_marshal_json(window_t *w);
json_t *window_list_marshal_json(window_list_t **head);

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
