#include <stdbool.h>
#include <stdlib.h>

typedef struct list {
	void *data;
	struct list *next;
} list_t;

/*
 * list_find_fn takes the data contained in a list item and an optional argument,
 * and returns true if the item is "found". This is used in pop and find functions.
 */
typedef bool (*list_find_fn)(void *data, void *arg);

/*
 * list_append takes a pointer to the first element of the list and appends an element containing
 * "data" to the end of the list.
 *
 * The head argument may point to a NULL pointer in the case of an empty list, in which case this
 * item will be updated to the inserted element.
 *
 *
 * list_append allocates memory using the stdlib allocator.
 */
void list_append(list_t **head, void *data);

/*
 * list_push takes a pointer to the first element of the list and puts an element containing "data"
 * at the start of the list.
 *
 * The head argument may point to a NULL pointer in the case of an empty list, in which case this
 * item will be updated to the inserted element.
 *
 * list_push allocates memory using the stdlib allocator.
 */
void list_push(list_t **head, void *data);

/*
 * list_pop takes a pointer to the first element of the list, a list_find_fn function and an
 * optional argument to be passed to the list_find_fn, and returns the data contained in the element
 * where list_find_fn is evaluated to "true" and removes the item from the list. Returns NULL if
 * item is not found
 *
 * The head argument may point to a NULL pointer in the case of an empty list, in which case NULL
 * is returned.
 *
 * If the list_find_fn is NULL, the first item of the list is used.
 *
 * list_pop deallocates memory using by the list.
 *
 */
void *list_pop(list_t **head, list_find_fn fn, void *arg);

/*
 * list_find behaves like list_pop but doesn't modify the list.
 */
void *list_find(list_t *head, list_find_fn fn, void *arg);

/*
 * list_len returns the number of items in the list.
 */
size_t list_len(list_t *head);
