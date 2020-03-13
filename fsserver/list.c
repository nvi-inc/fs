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
#include <stdbool.h>
#include <stdlib.h>

#include "list.h"

size_t list_len(list_t *head) {
	size_t len  = 0;
	list_t *ptr = head;
	while (ptr != NULL) {
		len++;
		ptr = ptr->next;
	}
	return len;
}

static bool truefn(void *data, void *arg) {
	(void)data;
	(void)arg;
	return true;
}

void *list_pop(list_t **head, list_find_fn fn, void *arg) {
	assert(head != NULL);

	if (*head == NULL)
		return NULL;

	if (fn == NULL)
		fn = truefn;

	list_t **prev_next = head;
	list_t *ptr        = *head;

	while (!fn(ptr->data, arg)) {
		prev_next = &ptr->next;
		ptr       = ptr->next;
		if (ptr == NULL)
			return NULL;
	}

	*prev_next = ptr->next;

	void *s = ptr->data;
	free(ptr);
	return s;
}

void *list_find(list_t *head, list_find_fn fn, void *arg) {
	list_t *ptr = head;
	if (fn == NULL)
		fn = truefn;
	while (ptr != NULL && !fn(ptr->data, arg))
		ptr = ptr->next;
	if (ptr == NULL)
		return NULL;
	return ptr->data;
}

void list_append(list_t **head, void *data) {
	list_t **prev_next = head;
	list_t *ptr        = *head;
	while (ptr != NULL) {
		prev_next = &ptr->next;
		ptr       = ptr->next;
	}

	list_t *new = calloc(sizeof(*new), 1);
	new->data   = data;
	*prev_next  = new;
}

void list_push(list_t **head, void *data) {
	list_t *new = calloc(sizeof(*new), 1);
	new->data   = data;
	new->next   = *head;
	*head       = new;
}
