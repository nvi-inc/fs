#ifndef INPUT_DEFD
#define INPUT_DEFD

#include "softkey.h"
#include "ext_init.h"

#define LAST_PARM  -1        /* pos return from nextparm() with last parm */

#define MAXX  80             /* number of screen columns */
#define MAXY  25             /* number of screen lines */

/*
 * Global variables
 */

EXTERN ibool ReadLnInsert INIT(TRUE);   /* insert mode on in readln_cmd(). */


void bell(void);
void belln(int n);

void wcurup(void);
void wcurdown(void);
void wcurleft(void);
void wcurright(void);

void readln(char* line, int maxsize);
void readln_cmd(const stree_ent* stree, char* line, int maxsize);

int nextparm(const char* cmd, char* result, int* pos, const char* delim);
char delimiter(const char* cmd, int pos, const char* delim);

int scan_cmd(char* cmdwd, const cmd_t commands[], const int num_cmds);

ibool are_you_sure(void);


#endif !INPUT_DEFD
