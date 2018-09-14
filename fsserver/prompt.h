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
