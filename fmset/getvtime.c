/* getvtime.c - get vlba formatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
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
	long centisec[6], centiavg, centidiff, hsdiff;
        int it[6];

        nsem_take("fsctl",0);
        if(get_vtime(centisec,it,ip,1)!=0) {
	  endwin();
	  fprintf(stderr,"Field System not running - fmset aborting\n");
	  exit(0);
	}
        nsem_put("fsctl");
	if( ip[2] != 1 )
		{
		endwin();
		fprintf(stderr,"Error %d from formatter\n",ip[2]);
                logita(NULL,ip[2],ip+3,ip+4);
                rte_sleep(SLEEP_TIME);
		exit(0);
		}

	/* time before is more accurate */

	centisec[1]=centisec[0];
	centisec[3]=centisec[2];
	centisec[5]=centisec[4];
	
        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
        rte_fixt(fstime,&centiavg);
        *fshs=centiavg;

	hsdiff=(centisec[3]-centisec[2])*100+centisec[5]-centisec[4];
	*unixhs=centisec[4]+(hsdiff/2)/100;
	*unixtime=centisec[2];
	if(*unixhs>=100) {
	  *unixtime+=*unixhs/100;
	  *unixhs=*unixhs%100;
	}

        rte2secs(it,formtime);
        *formhs=0;
}
