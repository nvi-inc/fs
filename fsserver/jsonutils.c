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
#include <stdio.h>
#include <stdarg.h>

int json_object_sprintf(json_t *obj, const char *key, char *const format, ...) {
	va_list args;
	char *buf;
	va_start(args, format);
	int sz = vasprintf(&buf, format, args);
	if (sz < 0) {
		return -1;
    }
	va_end(args);
	json_t *jstr = json_string(buf);
	json_object_set_new(obj, key, jstr);
	free(buf);
	return sz;
}
