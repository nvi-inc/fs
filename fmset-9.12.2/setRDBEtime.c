/* set5btime.c - set mk5b time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>
#include <string.h>
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "fmset.h"

void skd_run();
void skd_par();
void cls_snd();
int cls_rcv();
void cls_clr();

extern unsigned char inbuf[512];      /* class i-o buffer */
extern unsigned char outbuf[512];     /* class i-o buffer */
extern long inclass;         /* input class number */
extern long outclass;        /* output class number */
extern long ip[5];           /* parameters for fs communications */
extern int rtn1, rtn2, msgflg, save; /* unused cls_get args */
extern int iRDBE;

void setRDBEtime(formtime,delta)
time_t formtime;
int delta;
{
struct tm *fmtime;  /* pointer to tm structure */
int count;
 char *name;

	if(delta == 0) {
	  unsigned char *cp;
	  struct tm *formtm;
	  
	  formtm=gmtime(&formtime);
	  (void) strftime(outbuf,sizeof(outbuf),
			  "dbe_dot=%Y%j%H%M%S:force;\n",formtm);
	} else if (delta <0)
	  (void) strcpy(outbuf,"dbe_dot_inc=-1;\n");
	else
	  (void) strcpy(outbuf,"dbe_dot_inc=+1;\n");
	count=strlen(outbuf);
		
/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, count, 0, 0); 

ip[0] = 1;        /*mode*/
ip[1] = outclass; /* class number */
ip[2] = 1;        /* only one buf */
ip[3] = 0;
ip[4] = 0;

 if(1==iRDBE) {
   name="rdbca";
 } else if(2==iRDBE) {
   name="rdbcb";
  } else if(3==iRDBE) {
   name="rdbcc";
  } else if(4==iRDBE) {
   name="rdbcd";
  } else {
   endwin();
   fprintf(stderr,"Internal error in setRDBEtime, no RDBE selected %d\n",
	   iRDBE);
   rte_sleep(SLEEP_TIME);
   exit(0);
 }
 nsem_take("fsctl",0);

	while(skd_run_to(name,'w',ip,200)==1) {
	  if (nsem_test(NSEM_NAME) != 1) {
	    endwin();
	    fprintf(stderr,"Field System not running - fmset aborting\n");
	    exit(0);
	  }
	  name=NULL;
	}

nsem_put("fsctl");

/* get reply from mk5cn */
skd_par(ip);
inclass = ip[0];
if( ip[2] < 0 )
	{
	endwin();
	fprintf(stderr,"Error %d from rdbc%d\n",ip[2],iRDBE);
        logita(NULL,ip[2],ip+3,ip+4);
	cls_clr(outclass);
	cls_clr(inclass);
        rte_sleep(SLEEP_TIME);
	exit(0);
	}

cls_clr(outclass); /* clear class numbers just in case */
cls_clr(inclass);

}
