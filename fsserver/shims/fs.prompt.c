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
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <jansson.h>
#include <nng/nng.h>
#include <nng/protocol/pubsub0/sub.h>
#include <nng/protocol/reqrep0/req.h>
#include <nng/supplemental/util/platform.h>

#include "../../include/params.h"
#define fatal(msg, rv)                                                                             \
	fprintf(stderr, "%s:%d (%s) error %s: %s\n", __FILE__, __LINE__, __FUNCTION__, msg,        \
	        nng_strerror(rv));                                                                 \
	exit(1);

char *const server_cmd_url  = FS_SERVER_URL_BASE "/cmd";
char *const clients_cmd_url = FS_SERVER_URL_BASE "/clicmd";

int main(int argc, char *argv[]) {
	char *prompt_msg;
	bool cont = false;
	if (argc < 2) {
		exit(EXIT_FAILURE);
	}
	prompt_msg = argv[1];
	cont       = (argc == 3 && *argv[2] == '1');

	nng_socket server_cmd_sock;
	nng_socket clients_cmd_sock;
	int rv;

	if ((rv = nng_sub0_open(&clients_cmd_sock)) != 0) {
		fatal("nng_socket", rv);
	}

	rv = nng_setopt(clients_cmd_sock, NNG_OPT_SUB_SUBSCRIBE, NULL, 0);
	if (rv != 0) {
		fatal("nng_setopt", rv);
	}

	if ((rv = nng_dial(clients_cmd_sock, clients_cmd_url, NULL, 0)) != 0) {
		fatal("unable to connect to server", rv);
	}

	if ((rv = nng_req0_open(&server_cmd_sock)) != 0) {
		fatal("unable to open a request socket", rv);
	}

	if ((rv = nng_dial(server_cmd_sock, server_cmd_url, NULL, 0)) != 0) {
		fatal("unable to connect to server", rv);
	}

	json_t *jreq = json_object();
	json_object_set_new(jreq, "jsonrpc", json_string("2.0"));
	json_object_set_new(jreq, "id", json_integer(0));
	json_object_set_new(jreq, "method", json_string("prompt"));
	json_t *json_args = json_array();
	json_array_append_new(json_args, json_string("open"));
	json_array_append_new(json_args, json_string(prompt_msg));
	if (cont)
		json_array_append_new(json_args, json_string("1"));
	json_object_set_new(jreq, "params", json_args);

	size_t size = json_dumpb(jreq, NULL, 0, 0);
	char *buf   = nng_alloc(size);
	if (buf == NULL) {
		fatal("unable to allocate a new message", rv);
	}
	json_dumpb(jreq, buf, size, 0);
	json_decref(jreq);

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
		return EXIT_FAILURE;
	}

	json_error_t err;
	json_t *response = json_loadb(nng_msg_body(msg), nng_msg_len(msg), 0, &err);
	nng_msg_free(msg);

	if (!response) {
		fprintf(stderr, "server reply malformed: %s\n", err.text);
		return EXIT_FAILURE;
	}

	if (!json_is_object(response)) {
		fprintf(stderr, "server reply not an object\n");
		return EXIT_FAILURE;
	}

	// check for error
	json_t *error = json_object_get(response, "error");
	if (error) {
		json_t *err_msg = json_object_get(error, "message");
		json_t *code    = json_object_get(error, "code");
		if (!json_is_string(err_msg) && !json_is_integer(code)) {
			fprintf(stderr, "server returned an error but no message or code\n");
			return EXIT_FAILURE;
		}
		if (!json_is_integer(code)) {
			fprintf(stderr, "server returned error: %s\n", json_string_value(err_msg));
			return EXIT_FAILURE;
		}
		fprintf(stderr, "server returned error %lli: %s\n", json_integer_value(code),
		        json_string_value(err_msg));
		return EXIT_FAILURE;
	}

	json_t *prompt_json = json_object_get(json_object_get(response, "result"), "prompt");
	if (!json_is_object(prompt_json) || !json_is_integer(json_object_get(prompt_json, "id"))) {
		char *s = json_dumps(prompt_json, 0);
		fprintf(stderr, "server returned success but unknown value: %s\n", s);
		free(s);
		return EXIT_FAILURE;
	}

	json_int_t id = json_integer_value(json_object_get(prompt_json, "id"));
	json_decref(response);
	json_t *client_cmd;

	for (;;) {
		if ((rv = nng_recvmsg(clients_cmd_sock, &msg, 0)) != 0) {
			fatal("nng_recv", rv);
		}
		client_cmd = json_loadb(nng_msg_body(msg), nng_msg_len(msg), 0, &err);
		nng_msg_free(msg);

		json_t *method = json_object_get(client_cmd, "method");

		if (strcmp(json_string_value(method), "prompt_close") != 0) {
			json_decref(client_cmd);
			continue;
		}

		prompt_json = json_object_get(client_cmd, "params");
		if (!json_is_object(prompt_json) ||
		    !json_is_integer(json_object_get(prompt_json, "id"))) {
			json_decref(client_cmd);
			continue;
		}

		if (json_integer_value(json_object_get(prompt_json, "id")) != id) {
			json_decref(client_cmd);
			continue;
		}

		return EXIT_SUCCESS;
	}
}
