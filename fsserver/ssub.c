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
#include <assert.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <getopt.h>

#include <nng/nng.h>
#include <nng/protocol/pubsub0/sub.h>
#include <nng/protocol/reqrep0/req.h>

#include "msg.h"

void nng_perror(const char *msg, int rv) {
	fprintf(stderr, "ssub: %s: %s\n", msg, nng_strerror(rv));
	fflush(stderr);
}

#define error(msg, rv)                                                                             \
	fprintf(stderr, "ssub (%s:%d %s) error %s: %s\n", __FILE__, __LINE__, __FUNCTION__, msg,   \
	        nng_strerror(rv))

long long sync_msgs(int seq, char *addr, nng_duration timeout) {
	//  unsigned long long last_seq = 0;
	nng_socket sock;

	int rv;
	rv = nng_req0_open(&sock);
	if (rv != 0) {
		error("opening req socket", rv);
		return -1;
	}

	rv = nng_setopt_size(sock, NNG_OPT_RECVMAXSZ, 0);
	if (rv != 0) {
		error("setting recv size", rv);
		return -1;
	};

	rv = nng_setopt_ms(sock, NNG_OPT_RECVTIMEO, timeout);
	if (rv != 0) {
		error("setting timeout", rv);
		return -1;
	};

	rv = nng_setopt_ms(sock, NNG_OPT_SENDTIMEO, timeout);
	if (rv != 0) {
		error("setting timeout", rv);
		return -1;
	};

	rv = nng_dial(sock, addr, NULL, 0);
	if (rv != 0) {
		error("connecting to server", rv);
		return -1;
	}

	uint8_t outbuf[8];

	int outsize = uint64_marshal_le(seq, outbuf, 8);
	if (outsize < 0)
		return -1;

	rv = nng_send(sock, outbuf, outsize, 0);
	if (rv != 0) {
		error("sending syncing message to server", rv);
		return -1;
	}

	void *buf = NULL;
	size_t size;
	rv = nng_recv(sock, &buf, &size, NNG_FLAG_ALLOC);
	if (rv != 0) {
		error("connecting syncing with server", rv);
		return -1;
	}

	uint8_t *bptr = buf;
	msg_t m       = {DATA, 0, 0, NULL};
	size_t rem    = size;

	while (rem > 0) {
		int rcv_msg_size = msg_unmarshal(&m, bptr, rem);

		if (rcv_msg_size < 0)
			break;

		write(STDOUT_FILENO, m.data, m.len);

		if (m.data != NULL) {
			free(m.data);
			m.data = NULL;
		}

		bptr += rcv_msg_size;
		rem -= rcv_msg_size;
	};

	nng_free(buf, size);
	nng_close(sock);

	if (m.data != NULL) {
		free(m.data);
		m.data = NULL;
	}

	return m.seq;
}

// clang-format off
const char *usage_short_str = 
"Usage: %s [-swhp] [pubaddr syncaddr]\n";
const char *usage_long_str =  
"Usage: %s [-swhp] [pubaddr syncaddr]\n"
"subscribe to a reliable pubsub stream\n"
"  pubaddr, syncaddr   nanomsg addresses of publish and resync sockets\n"
"  -s, --scrollback    print full scrollback buffer on connection\n"
"  -w, --wait          wait for new connections if server shuts down\n"
"  -h, --help          print this message\n"
"  -p, --print-timeout print a message to stderr when waiting for connection \n";


static const struct option long_options[] = {
    {"scrollback",    no_argument, NULL, 's'},
    {"wait",          no_argument, NULL, 'w'},
    {"help",          no_argument, NULL, 'h'},
    {"print-timeout", no_argument, NULL, 'p'},

    {NULL, 0, NULL, 0}
};

// clang-format on

int main(int argc, char **argv) {

	// Default config
	char *pubaddr             = "tcp://127.0.0.1:4444";
	char *repaddr             = "tcp://127.0.0.1:4445";
	int perform_first_sync    = false;
	int exit_on_terminate_msg = true;
	int print_timeout         = false;

	// Hande flags
	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "swhp", long_options, &option_index)) != -1) {
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
		case 'p':
			print_timeout = true;
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
	// The strategy is to connect to the `pub` socket and read `msg`s If we notice
	// we're out of sync by inspecting `seq`, we connect to the rep socket and request
	// a resync.
	//
	// HEARTBEAT type `msg`s have the `seq` set to indicate the *next* valid DATA msg
	// that will be transmitted. If this is not what the client is expecting, it
	// should preform an out of band resync as with regular DATA msgs
	//
	// END_OF_SESSION type `msg`s indicate the server is shutting down gracefully. The
	// client can stay online or not (in this client determinted by the
	// `exit_on_terminate_msg` variable)

	int rv;
	nng_socket sock;

	if ((rv = nng_sub0_open(&sock)) != 0) {
		error("nng_socket", rv);
		exit(1);
	}
	rv = nng_setopt(sock, NNG_OPT_SUB_SUBSCRIBE, NULL, 0);

	if (rv != 0) {
		error("nng_setopt", rv);
		exit(1);
	}

	int timeout = 2000;
	rv          = nng_setopt_ms(sock, NNG_OPT_RECVTIMEO, timeout);
	if (rv != 0) {
		error("seting sub timeout", rv);
		exit(1);
	}

	if ((rv = nng_dial(sock, pubaddr, NULL, NNG_FLAG_NONBLOCK)) != 0) {
		error("nng_dial", rv);
		exit(1);
	}

	void *buf = NULL; // nng buffer msgs
	size_t sz;

	msg_t m = {DATA, 0, 0, NULL};

	// sequence id of the next msg we're expecting to receive
	uint64_t seq = 0;

	// Indicate if the client has printed to the terminal to inform the user
	// of a timeout
	// TODO: should only do this if stderr is a terminal
	bool printed_timeout = false;

	bool synced = false; // state of client
	for (;;) {
		if (buf != NULL) {
			nng_free(buf, sz);
			buf = NULL;
		}
		rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC);

		if (rv != 0) {
			if (rv == NNG_ETIMEDOUT) {
				if (print_timeout && !printed_timeout) {
					// TODO: make portable
					// TODO: save terminal style
					// TODO: make customizable
					fprintf(stderr, "\e[0;31mWaiting for "
					                "connection...\e[0m");
					fflush(stderr);
					printed_timeout = true;
				}
				continue;
			}
			error("error on recv", rv);
			exit(1);
		}

		if (print_timeout && printed_timeout) {
			fprintf(stderr, "\e[2K\r");
			fflush(stderr);
			printed_timeout = false;
		}

		if (m.data != NULL) {
			free(m.data);
			m.data = NULL;
		}

		int rc = msg_unmarshal(&m, buf, sz);
		if (rc < 0) {
			perror("error unmarshaling");
			exit(1);
		}

		// If we're not performing first sync, just start from the first message we receive
		if (!perform_first_sync) {
			perform_first_sync = true;
			synced             = true;
			seq                = m.seq;
		}

		// we could try a resync, but can't guarantee server will be around long enough to
		// reply, so we timeout after 1 second.
		if (m.type == END_OF_SESSION) {
			if (m.seq > seq) {
				sync_msgs(seq, repaddr, 1000);
			}
			if (exit_on_terminate_msg)
				break;
			continue;
		}

		if (m.seq < seq) {
			if (!synced) {
				// Ignore msgs we've already seen. This may happen during re-sync as
				// msgs received by OOB sync may also arrive at sub socket
				continue;
			}
			// If we're not rsyncing and we see a message with lower seq than we expect,
			// the server may have restarted, and we need to resync right from the
			// start.
			seq = 0;
		}

		if (m.seq > seq) {
			// We've missed a message, perform out-of-band sync
			synced      = false;
			long long s = sync_msgs(seq, repaddr, -1);
			if (s < 0) {
				continue;
			}
			// We may have gotten fewer or more messages than we were expecting.
			// If we got more next, we ensure
			// TODO: we should check if we got less here and do another resync
			seq = s + 1;
			continue;
		}

		if (!synced && m.seq == seq) {
			synced = true;
		}

		if (m.type == HEARTBEAT) {
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
		nng_free(buf, sz);
		buf = NULL;
	}
	nng_close(sock);
	return 0;
}
