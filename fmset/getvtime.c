/* getvtime.c - get vlba formatter time */

#include <curses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <sys/types.h>   /* data type definition header file */

extern long ip[5];           /* parameters for fs communications */

void rte2secs();

void getvtime(unixtime,unixhs,formtime,formhs)
time_t *unixtime; /* system time received from mcbcn */
int    *unixhs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
{
	long centisec[2], centiavg, centidiff;
        int it[6];

        get_vtime(centisec,it,ip);
	if( ip[2] != 1 )
		{
		endwin();
		printf("Error %d from formatter\n",ip[2]);
		exit(0);
		}

        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;

        rte_fixt(unixtime,&centiavg);
        *unixhs=centiavg;

        rte2secs(it,formtime);
        *formhs=0;
}
