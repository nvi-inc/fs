#ifndef MAIN_DEFD
#define MAIN_DEFD

#include "ext_init.h"

/*
 * Misc defines
 */
#define MAXSTRLEN  256
#undef TRUE
#undef FALSE
#define TRUE   (1==1)
#define FALSE  (1==0)

/* Local error codes */
#define ERR_NONE     0        /* No error has occurred */
#define ERR_OPFAIL  -1        /* Operation failed (non-specific error code) */


/*
 * Typedefs, we avoid using 'bool' because curses defines it (as a macro
 * in SunOS which is workable, but as a typedef in Solaris which is a killer)
 */
#ifndef IBOOL_DEFD
typedef int ibool;
#define IBOOL_DEFD
#endif


/*
 * Global variables 
 */
EXTERN ibool EndProgram INIT(FALSE);   /* flag to trigger system shutdown */

EXTERN int S2Addr INIT(0);            /* RCL address of S2 system to control */


/*
 * Function prototypes
 */
int main(int argc, char* argv[]);

#ifdef DOS
void chandler(void);
#endif DOS


#endif /* MAIN_DEFD */
