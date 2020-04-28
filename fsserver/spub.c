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
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include <getopt.h>

#include <errno.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/wait.h>

#include "msg.h"
#include "stream.h"

#include <nng/nng.h>
#include <nng/supplemental/util/platform.h>

#define fatal(msg)                                                                                 \
	do {                                                                                       \
		fprintf(stderr, "error [%s:%d (%s)]: %s\n", __FILE__, __LINE__, __FUNCTION__,      \
		        msg);                                                                      \
		exit(1);                                                                           \
	} while (0)

// clang-format off
static const char *usage_short_str =
"Usage: %s [-h] [-b length] [-w seconds] [pubaddr syncaddr]\n";
static const char *usage_long_str =
"Usage: %s [-h] [-b length] [-w seconds] [pubaddr syncaddr]\n"
"create to a reliable pubsub stream\n"
"  pubaddr, syncaddr    nanomsg addresses of publish and resync sockets\n"
"  -b, --buffer         number of previous messages (usually lines) to keep\n"
"  -w, --wait           number of seconds to wait for after stream closes (default 0.5) \n";


static struct option long_options[] = {
    {"help",   no_argument,       NULL, 'h'},
    {"buffer", required_argument, NULL, 'b'},
    {"wait",   required_argument, NULL, 'w'},
    {NULL, 0, NULL, 0}
};
// clang-format on

int main(int argc, char *argv[]) {
	char *pubaddr      = "tcp://*:4444";
	char *repaddr      = "tcp://*:4445";
	float wait_seconds = 0.5;

	size_t msg_buffer_len = 1000;

	int opt;
	int option_index;
	while ((opt = getopt_long(argc, argv, "hb:w:", long_options, &option_index)) != -1) {
		switch (opt) {
		case 0:
			// All long options are handled by their short form
			break;
		case 'h':
			printf(usage_long_str, argv[0]);
			exit(EXIT_SUCCESS);
			break;
		case 'b':
			msg_buffer_len = atoi(optarg);
			if (!msg_buffer_len)
				fatal("buffer length must be greater than 0");
			break;
		case 'w':
			wait_seconds = atof(optarg);
			if (wait_seconds < 0)
				fatal("wait can not be negative");
			break;
		default: /* '?' */
			fprintf(stderr, usage_short_str, argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	// Read the rest of the command line
	int nargs = argc - optind;
	if (nargs > 0) {
		if (nargs < 2) {
			fatal("pub address specified without rep address");
		}
		pubaddr = argv[optind];
		repaddr = argv[optind + 1];
	}

	char buf[8192];
	ssize_t n;

	buffered_stream_t *s;
	if ((buffered_stream_open(&s)) != 0)
		fatal("opening stream");

	buffered_stream_set_shutdown_period(s, wait_seconds * 1000);
	buffered_stream_set_len(s, msg_buffer_len);

	if (buffered_stream_listen(s, pubaddr, repaddr) != 0)
		fatal("opening listening");

	for (;;) {
		if ((n = read(STDIN_FILENO, buf, sizeof(buf))) <= 0) {
			break;
		}
		buffered_stream_send(s, buf, n);
	}

	buffered_stream_close(s);
	buffered_stream_join(s);

	return EXIT_SUCCESS;
}
