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
#include "prompt.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>

prompt_t *prompt_new() {
	return calloc(1, sizeof(prompt_t));
}

void prompt_free(prompt_t* p){
    free(p->message);
    free(p);
}

bool prompt_by_id(void *item, void *arg) {
	return ((prompt_t *)item)->id == *(unsigned *)arg;
}

bool prompt_by_pid(void *item, void *arg) {
	return ((prompt_t *)item)->pid == *(pid_t *)arg;
}

json_t *prompt_marshal_json(prompt_t *p) {
	assert(p);
	json_t *j = json_object();
	if (!j)
		return NULL;

	json_object_set_new(j, "id", json_integer(p->id));
	json_object_set_new(j, "message", json_string(p->message));
	json_object_set_new(j, "cont", json_boolean(p->cont));
	return j;
}

int prompt_unmarshal_json(prompt_t *p, json_t *j) {
    if (!p)
        return -1;
    int rv = json_unpack(j, "{s:s, s:i, s:b}", 
            "message", &p->message, 
            "id", &p->id,
            "cont", &p->cont);
    if (rv < 0) return -1;

    // p->message is owned by the json string, so need to dup
    p->message = strdup(p->message);
    return 0;
}
