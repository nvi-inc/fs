#ifndef SOFTKEY_DEFD
#define SOFTKEY_DEFD


/* Special non-alphabetic characters that can begin keywords: */
#define SPECIAL_CHARS  "+-:."

/* longest softkey entry before truncating for display (display limit
     is SKEY_SIZE)*/
#define MAXSOFTKEYSIZE   20

/* the maximum number of softkey labels in the 'soft_key' data type, must
     be more than the largest total number of labels that might be returned
     by stree_parse(), which is at least the number of commands. */
#define MAXSOFTLABELS   75


/* soft-key display parameters */
#define SKEY_NUM              8
#define SKEY_SIZE             7
#define SKEY_SPACING          10
#define SKEY_OFFSET           2
#define SKEY_Y                1      /* y position of softkey display */
#define SKEY_ETC              "--ETC--"
#define SKEY_DONE             "-DONE-"
#define SKEY_ERR              "**ERR**"


/*
 * Types
 */
enum stree_type {ST_NULL, ST_KEY, ST_STR, ST_NUM};

/* Syntax tree entry */
typedef struct stree_ent {
   enum stree_type type; 
   int maxsize;
   char value[MAXSOFTKEYSIZE];
   char desc[MAXSOFTKEYSIZE];
   struct stree_ent* next;
   struct stree_ent* child;
} stree_ent;

typedef char soft_key[MAXSOFTLABELS][MAXSOFTKEYSIZE];

#include "cmd.h"              /* must follow 'soft_key' type def */

stree_ent* stree_build(const cmd_t commands[], int num_cmds);
stree_ent* stree_build2(const char* format, int* pos);

ibool skeyword_char(char c);

void stree_leaves_set(stree_ent* head, stree_ent* target);

void stree_print(const stree_ent* head, char* pos);

int stree_parse(const char* cmd, int l, const stree_ent* head, 
                soft_key soft_labels, int* nlab, ibool* good_parse);
int stree_parse2(const char* cmd, int pos, int l, const stree_ent* tpos, 
                soft_key soft_labels, int* nlab, ibool* good_parse);

void add_labels(const stree_ent* entry, soft_key soft_labels, int* nlab);
void add_one_label(const stree_ent* entry, soft_key soft_labels, int* nlab);

int verify_syntax(const char* cmd, const stree_ent* stree_head);

void display_softkeys(soft_key soft_labels, int nlab, int first,
                      int left_trunc);


#endif not SOFTKEY_DEFD

