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
#include <stdbool.h>
#include <stdlib.h>

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
