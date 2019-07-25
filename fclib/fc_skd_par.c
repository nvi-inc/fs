#include <stdio.h>	/* standard I/O header file */
#include <sys/types.h>	/* standard data types definitions */
#include <string.h>    /* shared memory IPC header file */

void fc_skd_par__( ip)
long	ip[5];
{
    void skd_par();

    skd_par(ip);

    return;
}
