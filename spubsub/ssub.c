#include <assert.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <getopt.h>

#include <nanomsg/nn.h>
#include <nanomsg/pubsub.h>
#include <nanomsg/reqrep.h>

#include "msg.h"

static volatile int terminate = 0;
void term_handler(int i) {
	terminate = i;
}

void nn_perror(const char *msg) {
	fprintf(stderr, "ssub: %s: %s\n", msg, nn_strerror(nn_errno()));
	fflush(stderr);
}

long long sync_msgs(int seq, char *addr) {
	//  unsigned long long last_seq = 0;
	int fd = nn_socket(AF_SP, NN_REQ);

	int maxrcv = -1; // Unlimited
	if (nn_setsockopt(fd, NN_SOL_SOCKET, NN_RCVMAXSIZE, &maxrcv,
	                  sizeof(maxrcv)) < 0) {
		return -1;
	};

	if (nn_connect(fd, addr) < 0) {
		nn_perror("error on connect");
		return -1;
	}

	uint8_t outbuf[8];

	int rc = uint64_marshal_le(seq, outbuf, 8);
	if (rc < 0)
		return -1;

	if (nn_send(fd, outbuf, rc, 0) < 0)
		return -1;

	uint8_t *buf;
	rc = nn_recv(fd, &buf, NN_MSG, 0);
	if (rc < 0) {
		return -1;
	}

	uint8_t *bptr = buf;
	msg_t m       = {DATA, 0, 0, NULL};
	int rem       = rc;

	while (rem > 0) {
		rc = msg_unmarshal(&m, bptr, rem);

		if (rc < 0)
			break;

		write(STDOUT_FILENO, m.data, m.len);

		if (m.data != NULL) {
			free(m.data);
			m.data = NULL;
		}

		bptr += rc;
		rem -= rc;
	};
	nn_freemsg(buf);
	nn_close(fd);

	if (m.data != NULL) {
		free(m.data);
		m.data = NULL;
	}

	return m.seq;
}

const char *usage_short_str = "Usage: %s [-swh] [pubaddr repaddr]\n";
const char *usage_long_str =  "Usage: %s [-swh] [pubaddr repaddr]\n"
"subscribe to a reliable pubsub stream\n"
"  pubaddr, syncaddr   nanomsg addresses of publish and resync sockets\n"
"  -s, --scrollback    print full scrollback buffer on connection\n"
"  -w, --wait          wait for new connections if server shuts down\n"
"  -h, --help          print this message\n";

int main(int argc, char **argv) {

	// Default config
	char *pubaddr = "tcp://localhost:4444";
	char *repaddr = "tcp://localhost:4445";
	static int perform_first_sync    = false;
	static int exit_on_terminate_msg = true;

	static struct option long_options[] = {
	    {"scrollback", no_argument, NULL, 's'},
	    {"wait",       no_argument, NULL, 'w'},
	    {"help",       no_argument, NULL, 'h'},

	    {NULL, 0, NULL, 0}
	};

	// Hande flags
	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "swh", long_options,
	                          &option_index)) != -1) {
		switch (opt) {
		case 0:
			// All long options are handled by their short form
			break;
		case 's':
			perform_first_sync = true;
			break;
		case 'w':
			exit_on_terminate_msg = false;
			break;
		case 'h':
			fprintf(stderr, usage_long_str, argv[0]);
			exit(EXIT_SUCCESS);
			break;
		default: /* '?' */
			fprintf(stderr, usage_short_str, argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	int nargs = argc - optind;
	if (nargs > 0) {
		if (nargs < 2) {
			fprintf(stderr, "ssub: pub address specified without "
			                "rep address\n");
			exit(EXIT_FAILURE);
		}
		pubaddr = argv[optind];
		repaddr = argv[optind + 1];
	}

	// Now we're configured, let's get down to business...
	//
	// The strategy is to connect to the `pub` socket and read `msg`s
	// If we notice we're out of sync by inspecting `seq`, we connect to the
	// rep socket and request a resync.
	//
	// HEARTBEAT type `msg`s have the `seq` set to indicate the *next* valid
	// DATA msg that will be transmitted. If this is not what the client is
	// expecting, it should preform an out of band resync as with regular
	// DATA msgs
	//
	// END_OF_SESSION type `msg`s indicate the server is shutting down
	// gracefully. The client can stay online or not (in this client
	// determinted by the `exit_on_terminate_msg` variable)

	int sub = nn_socket(AF_SP, NN_SUB);

	int timeout = 2000;
	if (nn_setsockopt(sub, NN_SUB, NN_SUB_SUBSCRIBE, NULL, 0) <
	        0 || // Subscribe to anything
	    nn_setsockopt(sub, NN_SOL_SOCKET, NN_RCVTIMEO, &timeout,
	                  sizeof(timeout)) < 0) {
		nn_perror("error setting socket options");
		exit(1);
	}

	if (signal(SIGTERM, term_handler) == SIG_ERR ||
	    signal(SIGINT, term_handler) == SIG_ERR) {
		nn_perror("error setting signal handler");
		exit(1);
	}

	if (nn_connect(sub, pubaddr) < 0) {
		nn_perror("error connecting to pub socket");
		exit(1);
	}

	int nbytes;
	void *buf = NULL; // nanomsg buffer msgs
	msg_t m   = {DATA, 0, 0, NULL};
	uint64_t seq =
	    0; // sequence id of the next msg we're expecting to receive

	// Indicate if the client has printed to the terminal to inform the user
	// of a timeout
	// TODO: should only do this if stderr is a terminal
	bool printed_timeout = false;

	bool synced = false; // state of client
	for (;;) {
		if (buf != NULL) {
			nn_freemsg(buf);
			buf = NULL;
		}
		nbytes = nn_recv(sub, &buf, NN_MSG, 0);

		if (terminate) {
			fprintf(stderr, "\nclient exiting...\n");
			break;
		}

		if (nbytes < 0) {
			if (nn_errno() == ETIMEDOUT) {
				if (!printed_timeout) {
					// TODO: make portable and save style
					fprintf(stderr, "\e[0;31mWaiting for "
					                "connection...\e[0m");
					fflush(stderr);
					printed_timeout = true;
				}
				continue;
			}
			nn_perror("error on recv");
			exit(1);
		}

		if (printed_timeout) {
			// Clear line (assuming ANSI compatible terminal)
			// TODO: use ncurses
			fprintf(stderr, "\e[2K\r");
			fflush(stderr);
			printed_timeout = false;
		}

		if (m.data != NULL) {
			free(m.data);
			m.data = NULL;
		}
		int rc = msg_unmarshal(&m, buf, nbytes);
		if (rc < 0) {
			nn_perror("error unmarshaling");
		}

		if (m.type == END_OF_SESSION && exit_on_terminate_msg) {
			break;
		}

		// If we're not performing first sync, just start from
		// the first message we receive
		if (!perform_first_sync) {
			perform_first_sync = true;
			synced             = true;
			seq                = m.seq;
		}

		if (m.seq < seq) {
			if (!synced) {
				// Ignore msgs we've already seen. This may
				// happen during re-sync as msgs received by oob
				// sync may also arrive at sub socket
				continue;
			}
			// If we're not rsyncing and we see a message with lower
			// seq than we expect, the server may have restarted,
			// and we need to resync right from the start.
			seq = 0;
		}

		if (m.seq > seq) {
			// We've missed a message, perform out-of-band sync
			synced      = false;
			long long s = sync_msgs(seq, repaddr);
			if (s < 0) {
				nn_perror("error in sync_msgs");
				continue;
			}
			seq = s + 1;
			continue;
		}

		if (!synced && m.seq == seq) {
			synced = true;
		}

		if (m.type == HEARTBEAT) {
			// heartbeat msg, ignore
			continue;
		}

		seq = m.seq + 1;
		write(STDOUT_FILENO, m.data, m.len);
	}

	if (m.data != NULL) {
		free(m.data);
		m.data = NULL;
	}
	if (buf != NULL) {
		nn_freemsg(buf);
		buf = NULL;
	}
	nn_close(sub);
	nn_term();
	return 0;
}
