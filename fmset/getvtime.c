/* getvtime.c - get vlba formatter time */

#include <curses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <sys/types.h>   /* data type definition header file */

#include "fmset.h"

extern long ip[5];           /* parameters for fs communications */

void rte2secs();

void getvtime(unixtime,unixhs,fstime,fshs,formtime,formhs)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
{
	long centisec[2], centiavg, centidiff;
        int it[6];

        nsem_take("fsctl",0);
        get_vtime(centisec,it,ip);
        nsem_put("fsctl");
	if( ip[2] != 1 )
		{
		endwin();
		printf("Error %d from formatter\n",ip[2]);
                logita(NULL,ip[2],ip+3,ip+4);
                rte_sleep(SLEEP_TIME);
		exit(0);
		}

        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;

        rte_cmpt(unixtime,&centiavg);
        *unixhs=centiavg;

        centiavg= centisec[0]+centidiff/2;
        rte_fixt(fstime,&centiavg);
        *fshs=centiavg;

        rte2secs(it,formtime);
        *formhs=0;
}
