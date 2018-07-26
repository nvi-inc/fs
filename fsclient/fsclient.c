#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <pthread.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <wordexp.h>

#include <nng/nng.h>
#include <nng/protocol/pubsub0/sub.h>
#include <nng/protocol/reqrep0/req.h>
#include <nng/supplemental/util/platform.h>

#include <jansson.h>

#include "../include/ipckeys.h"
#include "../include/params.h"

#include "../include/fs_types.h"
#include "../include/fscom.h"

nng_mtx *pid_mtx;
pid_t prompt_pid;

// clib
int nsem_test(char *);
void setup_ids();
extern struct fscom *shm_addr;
void helpstr_(const char *cnam, int *clength, char *runstr, int *rack, int *drive1, int *drive2,
              int *ierr, int clen, int rlen);

volatile sig_atomic_t die   = 0;
volatile sig_atomic_t child = 0;

void call(char *command, char *flags);

void fatal(const char *func, int rv) {
	fprintf(stderr, "%s: %s\n", func, nng_strerror(rv));
	exit(1);
}

/* TODO: load these from a config somewhere */
char *const server_cmd_url  = "ipc:///run/fsserver/cmd";
char *const clients_cmd_url = "ipc:///run/fsserver/clicmd";

static char *strjoin(int argc, char *const argv[]) {
	if (argc <= 0) {
		return NULL;
	}

	size_t len = 0;
	for (int i = 0; i < argc; i++)
		len += strlen(argv[i]) + 1;

	char *s = malloc(len);

	char *to = s, *from;
	for (int i = 0; i < argc; i++) {
		from = argv[i];
		while (*from)
			*to++ = *from++;
		*to++ = ' ';
	}
	*--to = '\0';
	return s;
}

void clear_sigmask() {
	sigset_t set;
	sigemptyset(&set);
	pthread_sigmask(SIG_SETMASK, &set, NULL);
	sigprocmask(SIG_SETMASK, &set, NULL);
}

static int prompt_cmd(int argc, char *const argv[]) {
	if (argc < 2) {
		return 1;
	}

	if (strcmp(argv[1], "close") == 0) {
		nng_mtx_lock(pid_mtx);
		if (prompt_pid > 0) {
			kill(prompt_pid, SIGINT);
			prompt_pid = 0;
		}
		nng_mtx_unlock(pid_mtx);
		return 0;
	}

	if (strcmp(argv[1], "open") != 0) {
		return 1;
	}

	nng_mtx_lock(pid_mtx);
	switch (prompt_pid = fork()) {
	case -1:
		nng_mtx_unlock(pid_mtx);
		return 1;
	case 0:
		break;
	default:
		nng_mtx_unlock(pid_mtx);
		return 0;
	}

	int exec_argc = 0;
	char *exec_argv[3];

	exec_argv[exec_argc++] = "fs.prompt";
	exec_argv[exec_argc++] = strjoin(argc - 2, argv + 2);
	exec_argv[exec_argc]   = NULL;

	clear_sigmask();
	execvp(exec_argv[0], exec_argv);
	/* TODO handle error better?*/
	fatal("starting fs.prompt", errno);
	return 1;
}

static int window_cmd(int argc, char *const argv[]) {
	if (argc < 3) {
		return 1;
	}

	switch (fork()) {
	case -1:
		return 1;
	case 0:
		break;
	default:
		/* TODO wait for error check */
		return 0;
	}

	int exec_argc          = 0;
	char **const exec_argv = malloc(1024);

	if (exec_argv == NULL) {
		fatal("allocating memory", errno);
	}

	exec_argv[exec_argc++] = "xterm";

	for (int i = 3; i < argc; i++) {
		exec_argv[exec_argc++] = argv[i];
	}

	exec_argv[exec_argc++] = "-e";
	exec_argv[exec_argc++] = "ssub";
	exec_argv[exec_argc++] = "-s";
	exec_argv[exec_argc++] = argv[1];
	exec_argv[exec_argc++] = argv[2];
	exec_argv[exec_argc]   = NULL;

	clear_sigmask();

	execvp(exec_argv[0], exec_argv);
	/* TODO handle error better?*/
	fatal("starting xterm", errno);
	return 1;
}

struct cmd {
	const char *name;
	int (*cmd)(int argc, char *const argv[]);
};

static const struct cmd commands[] = {
    {"window", window_cmd},
    {"prompt", prompt_cmd},
    {NULL, NULL},
};

/*
 * ret -1 indicates internal error
 * return > 0 inidcates the command returned an error
 *
 */
int client_cmd(int argc, char *const argv[]) {
	if (argc <= 0) {
		return -1;
	}

	if (strlen(argv[0]) == 0) {
		return -1;
	}

	const struct cmd *ptr;
	for (ptr = commands; ptr->name; ptr++) {
		if (strcmp(ptr->name, argv[0]) == 0) {
			return ptr->cmd(argc, argv);
		}
	}

	return -1;
}

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

/* split string into two, adding null terminator
 * to input and returning second half (if any)*/
char *strsplit(char *in, char delim) {
	char *out = in;
	while (*out && *out != delim)
		out++;
	if (*out)
		*out++ = '\0';
	return out;
}

/* Kill all children processes with SIGINT */
void kill_children() {
	/* Ignore SIGINT so fsclient can shutdown cleanly */
	__sighandler_t p;
	if ((p = signal(SIGINT, SIG_IGN)) == SIG_ERR)
		fatal("fsclient: error killing children", errno);
	if (killpg(0, SIGINT) < 0)
		fatal("fsclient: error killing children", errno);
	if (signal(SIGINT, p) == SIG_ERR)
		fatal("fsclient: error killing children", errno);
}

void help(const char *arg) {
	char help_file[256] = {0};

	int err = 0;
	int i   = (int)(strlen(arg));
	/* TODO: this may cause problems on 64 bit */

	helpstr_(arg, &i, help_file, &shm_addr->equip.rack, &shm_addr->equip.drive[0],
	         &shm_addr->equip.drive[1], &err, 0, 0);

	if (err == -3) {
		fprintf(stderr, "fsclient: could not find help for \"%s\"\n", arg);
		return;
	}

	if (err == -2) {
		fprintf(stderr, "fsclient: help string too long");
		return;
	}

	if (err < 0) {
		fprintf(stderr, "fsclient: unknown error %d", err);
		return;
	}

	switch (fork()) {
	case -1:
		fatal("fsclient: error forking", errno);
	case 0:
		clear_sigmask();
		execlp("helpsh", "helpsh", help_file, NULL);
		perror("fsclient: error opening helpsh");
		_exit(EXIT_FAILURE);
	default:
		return;
	}
}

/*
 * Signal handler thread.
 * Watches the pid given in arg and executes a clean shutdown if it dies.
 * Also reaps zombie processes and handles terminate signals.
 */
void *signal_thread_fn(void *arg) {
	pid_t shudown_pid = *((pid_t *)arg);
	sigset_t set, emptyset;
	sigfillset(&set);
	pthread_sigmask(SIG_SETMASK, &set, NULL);
	while (!die) {
		sigemptyset(&emptyset);
		int ret = pselect(0, NULL, NULL, NULL, NULL, &emptyset);

		if (ret == -1 && errno != EINTR) {
			fatal("fsclient pselect error", errno);
		}

		if (child) {
			child = 0;
			if (signal(SIGCHLD, handler) == SIG_IGN)
				fatal("fsclient: error setting signal handler", errno);
			for (;;) {
				pid_t pid = waitpid(-1, NULL, WNOHANG);
				if (pid < 0 && errno != ECHILD) {
					fatal("poll", errno);
				}

				if (pid <= 0) {
					break;
				}

				if (pid == shudown_pid) {
					die = -1;
				}

				nng_mtx_lock(pid_mtx);
				if (pid == prompt_pid) {
					prompt_pid = 0;
					system("fsserver prompt close");
				}
				nng_mtx_unlock(pid_mtx);
			}
		}
	}
	if (die > 0) {
		// Killed by a signal, not main child
		fprintf(stderr, "\nclient exiting...\n");
	}
	kill_children();
	exit(EXIT_SUCCESS);
}

/*
 * handles commands from fsserver
 */
void *server_cmd_thread_fn(void *arg) {
	char *url = arg;
	nng_socket sock;
	int rv;
	nng_msg *msg;

	if ((rv = nng_sub0_open(&sock)) != 0) {
		fatal("nng_socket", rv);
	}
	rv = nng_setopt(sock, NNG_OPT_SUB_SUBSCRIBE, NULL, 0);

	if (rv != 0)
		fatal("nng_setopt", rv);

	if ((rv = nng_dial(sock, url, NULL, NNG_FLAG_NONBLOCK)) != 0) {
		fatal("nng_dial", rv);
	}

	for (;;) {
		if ((rv = nng_recvmsg(sock, &msg, 0)) != 0) {
			fatal("nng_recv", rv);
			/* TODO handle this better */
		}

		char *body = nng_msg_body(msg);
		if (body[nng_msg_len(msg)] != '\0') {
			nng_msg_append(msg, "\0", 1);
			body = nng_msg_body(msg);
		}

		wordexp_t cmdlist;

		rv = wordexp(body, &cmdlist, WRDE_NOCMD);
		if (rv != 0) {
			fatal("wordexp", rv);
			/* TODO handle this better */
		}

		rv = client_cmd(cmdlist.we_wordc, cmdlist.we_wordv);
	}

	nng_close(sock);
	return NULL;
}

/*
 * fetch_state queries the server to check if a prompt or any windows are open
 * and sets them up locally.
 *
 * TODO: doesn't do windows yet
 */
void fetch_state() {
	nng_socket server_cmd_sock;
	int rv;

	if ((rv = nng_req0_open(&server_cmd_sock)) != 0) {
		fatal("unable to open open a socket", rv);
	}

	if ((rv = nng_dial(server_cmd_sock, server_cmd_url, NULL, 0)) != 0) {
		fatal("unable to connect to server", rv);
	}

	json_t *json = json_object();
	json_object_set_new(json, "method", json_string("status"));

	json_t *json_args = json_array();

	json_array_append_new(json_args, json_string("commands"));
	json_object_set_new(json, "params", json_args);

	size_t size = json_dumpb(json, NULL, 0, 0);
	char *buf   = nng_alloc(size);
	if (buf == NULL) {
		fatal("unable to allocate a new message", rv);
	}

	json_dumpb(json, buf, size, 0);
	json_decref(json);

	rv = nng_send(server_cmd_sock, buf, size, NNG_FLAG_ALLOC);
	if (rv != 0) {
		fatal("unable to send message to server", rv);
	}

	nng_msg *msg;
	rv = nng_recvmsg(server_cmd_sock, &msg, 0);
	if (rv != 0) {
		fatal("error receiving message", rv);
	}

	nng_close(server_cmd_sock);

	if (nng_msg_len(msg) == 0) {
		fprintf(stderr, "server did not reply\n");
		return;
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

	json_t *reply_error = json_object_get(json, "error");
	if (reply_error) {
		json_t *msg = json_object_get(reply_error, "message");
		fprintf(stderr, "server error: %s\n", json_string_value(msg));
	}

	json_t *result = json_object_get(json, "result");
	if (!json_is_object(result)) {
		fprintf(stderr, "could not parse server response: ");
		json_dumpf(json, stderr, 0);
		fprintf(stderr, "\n");
		goto error;
	}

	json_t *message = json_object_get(result, "message");
	if (!json_is_string(message)) {
		fprintf(stderr, "could not parse server response: ");
		json_dumpf(json, stderr, 0);
		fprintf(stderr, "\n");
		goto error;
	}

	if (strlen(json_string_value(message)) == 0) {
		goto error;
	}

	char *cmds = strdup(json_string_value(message));

	char *cmd = strtok(body, "\n");
	while (cmd != NULL) {
		wordexp_t cmdlist;

		rv = wordexp(cmd, &cmdlist, WRDE_NOCMD);
		if (rv != 0) {
			fatal("wordexp", rv);
			/* TODO handle this better */
		}

		client_cmd(cmdlist.we_wordc, cmdlist.we_wordv);
		cmd = strtok(NULL, "\n");
	}

	free(cmds);
	json_decref(json);
	nng_msg_free(msg);
	return;

error:
	json_decref(json);
	nng_msg_free(msg);
	return;
}

void print_client_commands() {
	char *line = NULL;
	size_t len = 0;
	FILE *fp   = fopen(CLPGM_CTL, "r");
	if (!fp) {
		fprintf(stderr, "fsclient: error opening %s: %s\n", CLPGM_CTL, strerror(errno));
		return;
	}
	while (getline(&line, &len, fp) > 0) {
		if (line[0] == '\0' || line[0] == '\n' || line[0] == '*')
			continue;
		char *ptr = line;
		while (!isspace(*ptr))
			ptr++;
		*ptr = '\0';
		printf("%s\n", line);
	}

	free(line);
	fclose(fp);
}

/* Lookup commands in the file found at CLPGM_CTL and
 * pass to system(3).
 *
 * Understands flags in CLPGM_CTL:
 *
 *    a    start attached to to client, ie ends with client
 *    d    start detached, ie don't exit with client
 *
 * */
void run_clpgm_ctl(const char *cmd) {
	if (!cmd || cmd[0] == '\0') {
		printf("fsclient commands are:\n");
		print_client_commands();
		return;
	}

	FILE *fp = fopen(CLPGM_CTL, "r");
	if (!fp) {
		fprintf(stderr, "fsclient: error opening %s: %s\n", CLPGM_CTL, strerror(errno));
		return;
	}

	char *line    = NULL;
	size_t len    = 0;
	char *flags   = NULL;
	char *command = NULL;
	while (getline(&line, &len, fp) > 0) {
		if (line[0] == '\0' || line[0] == '\n' || line[0] == '*')
			continue;
		char *name = NULL;

		char *ptr = line;

		while (isspace(*ptr))
			ptr++;

		name = ptr;
		while (!isspace(*ptr))
			ptr++;
		while (isspace(*ptr))
			*ptr++ = '\0';

		if (strcmp(cmd, name) != 0)
			continue;

		flags = ptr;
		while (!isspace(*ptr))
			ptr++;
		while (isspace(*ptr))
			*ptr++ = '\0';

		command = ptr;

		break;
	}
	fclose(fp);

	if (!command) {
		fprintf(stderr, "fsclient: unknown command \"%s\"\n", cmd);
		return;
	}
	call(command, flags);
	free(line);
}

void call(char *command, char *flags) {
	switch (fork()) {
	default:
		return;
	case 0:
		break;
	case -1:
		fatal("fsclient: error creating new process", errno);
	}

	switch (flags[0]) {
	case 'd':
		if (setsid() < 0) {
			perror("fsclient: error starting a new session");
			_exit(EXIT_FAILURE);
		}
		switch (fork()) {
		default:
			_exit(EXIT_SUCCESS);
		case 0:
			break;
		case -1:
			fatal("fsclient: error creating new process", errno);
		}

		break;
	case 'a':
		break;
	default:
		fprintf(stderr, "fsclient: error starting command %s, unknown flag '%c'", command,
		        flags[0]);
		_exit(EXIT_SUCCESS);
	}

	clear_sigmask();
	execl("/bin/sh", "sh", "-c", command, NULL);
	perror("fsclient: error running command");
	_exit(EXIT_FAILURE);
}

const char *delim = " \t";
// Read a '*pgm.ctl' file (where * is 'fs' or 'stn')
int run_pgm_ctl(char *path) {
	FILE *fp = fopen(path, "r");
	if (!fp) {
		fprintf(stderr, "fsclient: error opening %s: %s\n", path, strerror(errno));
		return -1;
	}

	char *line = NULL;
	size_t len = 0;
	ssize_t read;

	int i = 0;

	while ((read = getline(&line, &len, fp)) > 0) {
		char *name = strtok(line, delim);
		if (!name)
			continue;

		if (name[0] == '*')
			continue;

		char *flags = strtok(NULL, delim);
		if (!flags)
			continue;

		// We only care about commands that require X11
		bool use_x = strchr(flags, 'x') != NULL;
		if (!use_x)
			continue;

		// strip off '&' if there is one
		char *cmd = strtok(NULL, "&");
		if (!cmd)
			continue;

		call(cmd, "a");
		i++;
	}

	free(line);
	fclose(fp);

	return i;
}

pid_t start_ssub(bool arg_scrollback, bool arg_wait) {
	int ssub_nargs     = 0;
	char *ssub_argv[6] = {NULL};

	ssub_argv[ssub_nargs++] = "ssub";
	if (arg_scrollback)
		ssub_argv[ssub_nargs++] = "-s";
	if (arg_wait)
		ssub_argv[ssub_nargs++] = "-w";

	ssub_argv[ssub_nargs++] = "ipc:///run/fsserver/windows/fs/pub";
	ssub_argv[ssub_nargs++] = "ipc:///run/fsserver/windows/fs/rep";

	pid_t ssub_pid = fork();
	if (ssub_pid < 0) {
		fatal("fsclient: error forking", errno);
	}
	if (ssub_pid == 0) {
		clear_sigmask();
		execvp("ssub", ssub_argv);
		perror("fsclient: error starting ssub");
		_exit(EXIT_FAILURE);
	}
	return ssub_pid;
}

const char *usage_short_str = "Usage: %s [-swfnh] \n";
const char *usage_long_str  = "Usage: %s [-swfnh] \n"
                             "Connect to local Field System server, starting any X11 programs\n"
                             "in fspgm.ctl or stpgm.ctl\n"
                             "  -s, --scrollback      print full scrollback buffer on connect\n"
                             "  -w, --wait            wait for Field System to restart on exit\n"
                             "  -f, --force           start even if Field System is not running\n"
                             "  -n, --no-x            do not start programs requring X11\n"
                             "  -h, --help            print this message\n";

// clang-format off
static struct option long_options[] = {
    {"scrollback", no_argument, NULL, 's'},
    {"wait",       no_argument, NULL, 'w'},
    {"force",      no_argument, NULL, 'f'},
    {"no-x",       no_argument, NULL, 'n'},
    {"help",       no_argument, NULL, 'h'},
    {NULL, 0, NULL, 0}};
// clang-format on

int main(int argc, char **argv) {
	int rv;
	bool arg_scrollback = false;
	bool arg_wait       = false;
	bool arg_force      = false;
	bool arg_no_x       = false;

	// TODO: check if X11 available
	// TODO: todo add CLI flag

	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "swfnh", long_options, &option_index)) != -1) {
		switch (opt) {
		case 0:
			// All long options are flags which are handled by
			// getopt_long
			break;
		case 's':
			arg_scrollback = true;
			break;
		case 'w':
			arg_wait = true;
			break;
		case 'f':
			arg_force = true;
			break;
		case 'n':
			arg_no_x = true;
			break;
		case 'h':
			printf(usage_long_str, argv[0]);
			exit(EXIT_SUCCESS);
			break;
		default: /* '?' */
			fprintf(stderr, usage_short_str, argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	setup_ids();
	if (!arg_force && !nsem_test("fs   ")) {
		fprintf(stderr, "Field System not running, run \"fs\" first\n");
		exit(EXIT_FAILURE);
	}

	if (signal(SIGINT, handler) == SIG_ERR || signal(SIGQUIT, handler) == SIG_ERR ||
	    signal(SIGTERM, handler) == SIG_ERR || signal(SIGCHLD, handler) == SIG_ERR) {
		fatal("fsclient: error setting signals", errno);
	}

	// signals are handled by other thread, block in this thread
	sigset_t set;
	sigfillset(&set);
	pthread_sigmask(SIG_BLOCK, &set, NULL);

	pid_t ssub_pid = start_ssub(arg_scrollback, arg_wait);

	// setup pipe for children (oprin) to give commands to client
	int fds[2];
	if (pipe(fds) < 0) {
		fatal("fsclient: error on pipe", errno);
	}
	// children shouldn't be reading from the pipe
	if (fcntl(fds[0], F_SETFD, fcntl(fds[0], F_GETFD) | FD_CLOEXEC) < 0) {
		fatal("fsclient: error setting close-on-exec flag", errno);
	}

	char buf[256];
	snprintf(buf, sizeof(buf), "%d", fds[1]);
	if (setenv("FS_CLIENT_PIPE_FD", buf, 1) < 0) {
		perror("fsclient: error setenv");
		exit(EXIT_FAILURE);
	}

	if (!arg_no_x) {
		// Start other programs
		int ret;
		ret = run_pgm_ctl(FSPGM_CTL);
		if (ret < 0)
			fatal("fsclient: error starting fs programs", errno);
		ret = run_pgm_ctl(STPGM_CTL);
		if (ret < 0)
			fatal("fsclient: error starting station programs", errno);
	}

	close(fds[1]);

	rv = nng_mtx_alloc(&pid_mtx);
	if (rv != 0) {
		fatal("fsclient: error on mtx_alloc", rv);
	}

	// setup signal  ssub terminates, terminate client
	pthread_t signal_thread;
	if (pthread_create(&signal_thread, NULL, signal_thread_fn, &ssub_pid)) {
		fatal("fsclient: error on pthread_create", errno);
	}
	/* TODO: get these from a config file */
	/* char *server_cmd_url  = "ipc:///tmp/fs/cli"; */
	pthread_t server_cmd_thread;
	if (pthread_create(&server_cmd_thread, NULL, server_cmd_thread_fn, clients_cmd_url)) {
		fatal("fsclient: error on pthread_create", errno);
	}

	fetch_state();

	char *command = NULL;
	char *arg     = NULL;
	ssize_t len;
	size_t n;
	FILE *f = fdopen(fds[0], "r");

	while ((len = getline(&command, &n, f)) >= 0) {
		if (command[len - 1] == '\n') {
			command[len - 1] = '\0';
			len--;
		}

		arg = strsplit(command, '=');

		if (strcasecmp(command, "exit") == 0) {
			kill_children();
			exit(EXIT_SUCCESS);
		}

		if (strcasecmp(command, "help") == 0) {
			help(arg);
			continue;
		}

		// Lookup in clpgm.ctl
		// args aren't used here. Perhaps in the future?
		run_clpgm_ctl(command);
	}
	free(command);

	/* Only get here if pipe closed, i.e all
	 * children other than ssub exited.
	 *
	 * Keep running until ssub exits */
	pthread_join(signal_thread, NULL);
	exit(EXIT_SUCCESS);
}
