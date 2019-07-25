#include <stdio.h>	/* standard I/O header file */
#include <sys/types.h>	/* standard data types definitions */
#include <string.h>    /* shared memory IPC header file */

void fc_skd_run__( name, wait, ip,lenn,lenw)
char	name[5], *wait;	
int     lenn, lenw;
long	ip[5];
{
    void skd_run();

    skd_run(name,*wait,ip);

    return;
}
