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
#include <inttypes.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <jansson.h>

#include "jsonutils.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_BUF 512

extern struct fscom *shm_addr;
void skd_boss_inject_w(int *class, const char *buffer, size_t length);
int cls_rcv(int class, char *buffer, int length, int *rtn1, int *rtn2, int msgflg, int save);
void setup_ids();
void skd_par(int *);

static bool called_setup_ids = false;

int inject_snap(json_t *rep_msg, const char *command) {
	int i;
	int nchar, rtn1, rtn2;
	char buf[MAX_BUF + 1];
	int ip[5] = {};
	if (!called_setup_ids) {
		setup_ids();
		called_setup_ids = true;
	}
	size_t length = strlen(command);
	skd_boss_inject_w(&(shm_addr->iclopr), command, length);
	skd_par(ip);

	json_t *result = json_array();

	for (i = 0; i < ip[1]; i++) {
		int kack;
		char *ich, buf2[MAX_BUF];

		nchar = cls_rcv(ip[0], buf, MAX_BUF, &rtn1, &rtn2, 0, 0);
		if (nchar < 0)
			nchar = 0;
		else if (nchar > MAX_BUF)
			nchar = MAX_BUF;

		buf[nchar] = '\0';

		/* check for only ACKs */
		strcpy(buf2, buf);
		ich  = strchr(buf2, '/');
		kack = ich != NULL;
		if (kack) {
			/* ich now points to spot '/' */
			ich++;
			kack = (ich = strtok(ich, ",")) != NULL && strncmp(ich, "ack", 3) == 0;
			while (kack && (ich = strtok(NULL, ",")) != NULL) {
				kack = strncmp(ich, "ack", 3) == 0;
			}
		}
		if (!kack) {
            json_array_append_new(result, json_string(buf));
		}
	}

	// TODO: get error message. Need to wait for #50 to be fixed
	if (ip[2] != 0) {
        json_decref(result);
        json_object_sprintf(rep_msg, "message", "fs returned error code %d", ip[2]);
        json_object_set_new(rep_msg, "code", json_integer(ip[2]));
        return ip[2];
	}
    json_object_set_new(rep_msg, "messages", result);

	return 0;
}
