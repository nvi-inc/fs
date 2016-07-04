/* getRBEtime.c - get RDBE formatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "../include/params.h"

#include "fmset.h"

extern long ip[5];           /* parameters for fs communications */
extern int synch;
extern int rack, rack_type;
extern int iRDBE;

void rte2secs();

void getRDBEtime(unixtime,unixhs,fstime,fshs,formtime,formhs,raw,vdif_epoch)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
long *raw;
int *vdif_epoch;
{
	long centisec[6], centiavg, centidiff, hsdiff;
        int it[6];
	char *name;
	char *str;
	int out_recs;
	long out_class;

	if(synch) {
	  out_recs=0;
	  out_class=0;

	  str="dbe_sync=;\n";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;
	     
	  ip[0]=1;
	  ip[1]=out_class;
	  ip[2]=out_recs;
	  
	  if(1==iRDBE) {
	    name="rdbca";
	    logit("rdbe-A sync command sent.",0,NULL);
	  } else if(2==iRDBE) {
	    name="rdbcb";
	    logit("rdbe-B sync command sent.",0,NULL);
	  } else if(3==iRDBE) {
	    name="rdbcc";
	    logit("rdbe-C sync command sent.",0,NULL);
	  } else if(4==iRDBE) {
	    name="rdbcd";
	    logit("rdbe-D sync command sent.",0,NULL);
	  } else {
	    endwin();
	    fprintf(stderr,"Internal error in getRDBEtime, no RDBE selected\n");
	    rte_sleep(SLEEP_TIME);
	    exit(0);
	  }
	  nsem_take("fsctl",0);
	  while(skd_run_to(name,'w',ip,120)==1) {
	    if (nsem_test("fs   ") != 1) {
	      endwin();
	      fprintf(stderr,"Field System not running - fmset aborting\n");
	      exit(0);
	    }
	    name=NULL;
	  }
	  skd_par(ip);
	  nsem_put("fsctl");
	  if(ip[2] != 0)
	    {
	      endwin();
	      fprintf(stderr,"Error %d from rdbc%d\n",ip[2],iRDBE);
	      logita(NULL,ip[2],ip+3,ip+4);
	      rte_sleep(SLEEP_TIME);
	      exit(0);
	    }
	  if(ip[1]!=0)
	    cls_clr(ip[0]);
	  synch=0;
	}


        nsem_take("fsctl",0);
        if(get_RDBEtime(centisec,it,ip,1,iRDBE,vdif_epoch)!=0) {
	  endwin();
	  fprintf(stderr,"Field System not running - fmset aborting\n");
	  exit(0);
	}
        nsem_put("fsctl");
	if( ip[2] != 0 )
		{
		endwin();
		fprintf(stderr,"Error %d from rdbc%d\n",ip[2],iRDBE);
                logita(NULL,ip[2],ip+3,ip+4);
                rte_sleep(SLEEP_TIME);
		exit(0);
		}

	/* time after is more accurate */
	
	centisec[0]=centisec[1];
	centisec[2]=centisec[2];
	centisec[4]=centisec[5];

        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
	*raw=centiavg;

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
        *formhs=it[0];
}
