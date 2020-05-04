#include "convey.h"
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include "../list.c"

typedef struct { int id; } test_t;

test_t *new (int id) {
	test_t *ret = calloc(1, sizeof(test_t));
	ret->id     = id;
	return ret;
}

bool find_by_id(void *data, void *arg) {
	test_t *t = data;
	int id    = *((int *)arg);
	if (t->id == id)
		return true;
	return false;
}

Main({
	Test("Window list operations", {
		Convey("Given empty list", {
			list_t *l = NULL;

			Convey("we can append", {
				test_t *w = new (1);
				w->id     = 1;
				list_append(&l, w);
				So(l != NULL);

				w = new (2);
				So(w != NULL);
				list_append(&l, w);

				Convey("and list preserves order", {
					w = list_pop(&l, NULL, NULL);
					So(w->id == 1);
					free(w);
					w = list_pop(&l, NULL, NULL);
					So(w->id == 2);
				});

				Convey("and length is correct", { So(list_len(l) == 2); });

				Convey("push works", {
					int id = 3;
					list_push(&l, new (id));
					So(l != NULL);
					w = list_pop(&l, find_by_id, &id);
					So(w->id == id);
				});

				Convey("find works", {
					w = list_find(l, NULL, NULL);
					So(w->id == 1);
				});

				Convey("find by id works", {
					int id = 1;
					w      = list_find(l, find_by_id, &id);
					So(w != NULL);
					So(w->id == 1);
					id = 2;
					w  = list_find(l, find_by_id, &id);
					So(w != NULL);
					So(w->id == 2);
				});

				Convey("find by id handles not found", {
					int id = 3;
					So(list_find(l, find_by_id, &id) == NULL);
				});

				Convey("pop works", {
					w = list_pop(&l, NULL, NULL);
					So(w != NULL);
					So(w->id == 1);
					w = list_pop(&l, NULL, NULL);
					So(w != NULL);
					So(w->id == 2);
					w = list_pop(&l, NULL, NULL);
					So(w == NULL);
				});

				Convey("pop by id works", {
					int id = 2;
					w      = list_pop(&l, find_by_id, &id);
					So(w != NULL);
					So(w->id == 2);
					So(l->next == NULL);
					free(w);
				});

				Convey("pop can handle missing element", {
					int id = 2;
					list_pop(&l, find_by_id, &id);
					w = list_pop(&l, find_by_id, &id);
					So(w == NULL);
				});

				Convey("pop can empty list ", {
					int id = 2;
					list_pop(&l, find_by_id, &id);
					id = 1;
					list_pop(&l, find_by_id, &id);
					So(l == NULL);
				});

			});
		});
	});
});
