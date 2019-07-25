#include <stdio.h>	/* standard I/O header file */
#include <sys/types.h>	/* standard data types definitions */
#include <string.h>    /* shared memory IPC header file */

void fc_skd_arg__( n, buff, len)
char	*buff;	
int     *n, len;
{
    void skd_arg();

    skd_arg(*n, buff ,len);

    return;
}
