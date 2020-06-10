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
