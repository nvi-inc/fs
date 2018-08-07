#include <stdbool.h>
#include <stdlib.h>

#define FS_SERVER_BASE_PATH "/run/fsserver"


typedef struct server server_t;

int server_new(server_t**);
int server_start(server_t*);
bool server_is_running(server_t *s);
int server_finished_fd(server_t *s);
int server_start_fs(server_t *s);
void server_destroy(server_t *s);
void server_shutdown(server_t *s);
void server_sigchld_cb(server_t *s, pid_t pid, int status);
void server_sigterm_cb(server_t *s);
