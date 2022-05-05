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
#include <jansson.h>
#include <stdbool.h>

#include <stdbool.h>
typedef struct {
	unsigned id;
	char *message;
	bool cont;
    pid_t pid;
} prompt_t;

bool prompt_by_id(void *, void *);
bool prompt_by_pid(void *, void *);

prompt_t *prompt_new();
void prompt_free(prompt_t *);
json_t *prompt_marshal_json(prompt_t *);
int prompt_unmarshal_json(prompt_t *p, json_t *j);
