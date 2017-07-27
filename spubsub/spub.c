#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include <getopt.h>

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

#include <sys/ioctl.h>
#include <termios.h>

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/wait.h>

#include <nanomsg/nn.h>
#include <nanomsg/pubsub.h>
#include <nanomsg/reqrep.h>
#include <pthread.h>

#include "msg.h"

uint64_t seq          = 0; // Next message sequence ID to send
size_t msg_buffer_len = 1024;
msg_t *msg_buffer     = NULL; // Ring buffer of messages
pthread_mutex_t msg_buffer_lock;

static volatile int terminate = 0;
void term_handler(int i) {
	terminate = i;
}

void nn_perror(const char *msg) {
	printf("spub: %s: %s\n", msg, nn_strerror(errno));
}

// Thread to manange out-of-band sync
// rep socket recieves the sequence numer it last saw
// and replies with all messages after that in the buffer
void *sync_manager(void *arg) {
	int fd = (intptr_t)arg;

	void *buf;
	for (;;) {
		int rc = nn_recv(fd, &buf, NN_MSG, 0);
		if (rc < 0) {
			if (nn_errno() == EBADF) {
				return NULL; // Socket closed by another thread.
			}
			/*  Any error here is unexpected. */
			fprintf(stderr, "spub: nn_recv error: %s\n",
			        nn_strerror(nn_errno()));
			nn_close(fd);
			break;
		}
		uint64_t req_seq;
		int n = uint64_unmarshal_le(&req_seq, buf, rc);
		nn_freemsg(buf);
		if (n < 0) {
			fprintf(stderr, "spub: bad msg");
			continue;
		}

		if (pthread_mutex_lock(&msg_buffer_lock) < 0) {
			nn_perror("error locking msgs for read");
			continue;
		}

		if (seq == 0 || req_seq >= seq) {
			// TODO: send empty reply
			nn_send(fd, "", 1, 0);
			goto unlock;
		}

		// Cache of msgs,
		// Find the first message requested
		int first = seq % msg_buffer_len; // oldest message
		if (msg_buffer[first].data == NULL)
			first = 0; // if buffer hasn't filled yet
		while (msg_buffer[first].seq < req_seq) {
			first = (first + 1) % msg_buffer_len;
		}

		size_t rep_msg_size = 0;

		//fprintf(stderr, "sending %lu to %lu\n", msg_buffer[first].seq, seq - 1);
		// NB (seq-1) is the last seq posted
		for (int j = first;; j = (j + 1) % msg_buffer_len) {
			rep_msg_size += msg_marshaled_len(&msg_buffer[j]);
			if (msg_buffer[j].seq == seq - 1)
				break;
		}

		uint8_t *rep_msg = nn_allocmsg(rep_msg_size, 0);
		if (!rep_msg) {
			nn_perror("error allocating reply msg");
			_exit(1);
		}

		uint8_t *rep_ptr = rep_msg;
		size_t msg_len   = 0;

		for (int j = first;; j = (j + 1) % msg_buffer_len) {
			n = msg_marshal(&msg_buffer[j], rep_ptr,
			                rep_msg_size - msg_len);
			if (n < 0) {
				fprintf(stderr, "spub: error marshaling msg\n");
				_exit(1);
			}
			rep_ptr += n;
			msg_len += n;

			if (msg_buffer[j].seq == seq - 1)
				break;
		}

		if (msg_len != rep_msg_size) {
			fprintf(stderr, "spub: msg smaller than anticipated\n");
			_exit(1);
		}

		rc = nn_send(fd, &rep_msg, NN_MSG, 0);
		// fprintf(stderr, "sent %d bytes\n", rc);

	unlock:
		if (pthread_mutex_unlock(&msg_buffer_lock) < 0) {
			nn_perror("error unlocking msgs from read");
			continue;
		}
	}
	return NULL;
}

ssize_t send_msg(int nnsock, msg_t *m) {
	ssize_t pub_len  = msg_marshaled_len(m);
	uint8_t *pub_buf = nn_allocmsg(pub_len, 0);

	if (pub_buf == NULL) {
		return -1;
	}
	if (msg_marshal(m, pub_buf, pub_len) < 0) {
		return -1;
	}
	if (nn_send(nnsock, &pub_buf, NN_MSG, 0) < 0) {
		return -1;
	};

	return pub_len;
}

const char *usage_short_str = "Usage: %s [-h] [-b length] [pubaddr repaddr]\n";
const char *usage_long_str  = "Usage: %s [-h] [-b length] [pubaddr repaddr]\n"
"create to a reliable pubsub stream\n"
"  pubaddr, syncaddr    nanomsg addresses of publish and resync sockets\n"
"  -b, --buffer         number of previous messages (usually lines) to keep\n";

int main(int argc, char *argv[]) {
	// Default config
	char *pubaddr = "tcp://*:4444";
	char *repaddr = "tcp://*:4445";

	// Hande flags
	static struct option long_options[] = {
	    {"help", no_argument, NULL, 'h'},
	    {"buffer", required_argument, NULL, 'b'},

	    {NULL, 0, NULL, 0}
	};

	// Hande flags
	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "hb:", long_options,
	                          &option_index)) != -1) {
		switch (opt) {
		case 0:
			// All long options are handled by their short form
			break;
		case 'h':
			printf(usage_long_str, argv[0]);
			_exit(EXIT_SUCCESS);
			break;
		case 'b':
			msg_buffer_len = atoi(optarg);
			if (!msg_buffer_len) {
				fprintf(stderr, "spub: buffer length must be "
				                "greater than 0");
				_exit(EXIT_FAILURE);
			}
			break;
		default: /* '?' */
			fprintf(stderr, usage_short_str, argv[0]);
			_exit(EXIT_FAILURE);
		}
	}

	// Read the rest of the command line
	int nargs = argc - optind;
	if (nargs > 0) {
		if (nargs < 2) {
			fprintf(stderr, "spub: pub address specified without "
			                "rep address\n");
			_exit(EXIT_FAILURE);
		}
		pubaddr = argv[optind];
		repaddr = argv[optind + 1];
	}

	msg_buffer = calloc(msg_buffer_len, sizeof(msg_t));

	if (!msg_buffer) {
		perror("spub: unable to allocate msg buffer");
		_exit(EXIT_FAILURE);
	}

	if (signal(SIGTERM, term_handler) == SIG_ERR ||
	    signal(SIGINT, term_handler) == SIG_ERR) {
		nn_perror("error setting signal handler");
		_exit(EXIT_FAILURE);
	}

	bool err = 0;

	int pub = nn_socket(AF_SP, NN_PUB);
	if (nn_bind(pub, pubaddr) < 0) {
		nn_perror("spub: error on publish socket bind");
		_exit(1);
	}

	int rep  = nn_socket(AF_SP, NN_REP);
	int prio = 1;
	nn_setsockopt(rep, NN_SOL_SOCKET, NN_SNDPRIO, &prio, sizeof(prio));
	if (nn_bind(rep, repaddr) < 0) {
		nn_perror("spub: error on reply socket bind");
		nn_close(pub);
		_exit(1);
	}

	/*
	// GNU extensions
	pthread_rwlockattr_t attr;
	pthread_rwlockattr_setkind_np(&attr,
	PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP);
	pthread_rwlock_init(&msgs_lock, &attr);
	*/
	/* pthread_rwlock_init(&msg_buffer_lock, NULL); */
	pthread_mutex_init(&msg_buffer_lock, NULL);

	pthread_t rep_thread;
	if (pthread_create(&rep_thread, NULL, sync_manager,
	                   (void *)(intptr_t)rep) < 0) {
		nn_perror("spub: error creating reply thread");
		_exit(1);
	}

	fd_set rfds;
	struct timeval tv;
	char buf[8192];
	ssize_t n;

	for (;;) {
		FD_ZERO(&rfds);
		FD_SET(STDIN_FILENO, &rfds);
		tv.tv_sec  = 1;
		tv.tv_usec = 500000;

		int retval = select(STDIN_FILENO + 1, &rfds, NULL, NULL, &tv);

		if (terminate) {
			break;
		}

		if (retval < 0) {
			nn_perror("error on select");
			err = true;
			break;
		}

		if (retval == 0) {
			msg_t m = {HEARTBEAT, seq, 0, NULL};
			if (send_msg(pub, &m) < 0) {
				nn_perror("error on sending HEARTBEAT");
				err = true;
				break;
			}
			continue;
		}

		if ((n = read(STDIN_FILENO, buf, sizeof(buf))) < 0) {
			nn_perror("error on read");
			err = true;
			break;
		}

		if (n == 0) {
			break;
		}

		if (pthread_mutex_lock(&msg_buffer_lock) < 0) {
			nn_perror("error locking rwlock for write");
			err = true;
			break;
		}

		size_t i = seq % msg_buffer_len;

		if (msg_buffer[i].data != NULL) {
			free(msg_buffer[i].data);
			msg_buffer[i].data = NULL;
		}

		char *data = malloc(n);
		if (data == NULL) {
			nn_perror("error allocating msg");
			err = true;
			break;
		}

		msg_buffer[i].type = DATA;
		msg_buffer[i].data = memcpy(data, buf, n);
		msg_buffer[i].len  = n;
		msg_buffer[i].seq  = seq++;

		if (send_msg(pub, &msg_buffer[i]) < 0) {
			nn_perror("error sending msg");
			err = true;
			break;
		}

		if (pthread_mutex_unlock(&msg_buffer_lock) < 0) {
			nn_perror("error unlocking rwlock");
			err = true;
			break;
		}
	}

	// Send end of session to subscribers
	msg_t m = {END_OF_SESSION, seq, 0, NULL};
	send_msg(pub, &m);

	nn_close(pub);
	nn_close(rep);
	nn_term();

	for (size_t i = 0; i < msg_buffer_len; i++) {
		if (msg_buffer[i].data != NULL)
			free(msg_buffer[i].data);
	}
	free(msg_buffer);
	pthread_mutex_destroy(&msg_buffer_lock);
	pthread_join(rep_thread, NULL);
	return err;
}
