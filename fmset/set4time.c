/* set4time.c - set mk4 formatter time */

#include <curses.h>      /* ETI curses standard I/O header file */
#include <memory.h>
#include <string.h>
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */

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

void set4time(formtime,delta)
time_t formtime;
int delta;
{
struct tm *fmtime;  /* pointer to tm structure */
short sh9={9};
int count;

	memcpy(outbuf,&sh9,2);

	if(delta == 0) {
		unsigned char *cp;
		(void) cftime(outbuf+2,"fm/tim %Y %j %H %M %S",&formtime);
		for (cp=outbuf+2;*cp!='\0';cp++)
			if(*cp==' '&&*(cp+1)=='0')
				*(cp+1)=' ';
	} else if (delta <0)
		(void) strcpy(outbuf+2,"fm /tre");
	else
		(void) strcpy(outbuf+2,"fm /tad");
	count=strlen(outbuf+2)+2;
		

/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, count, 0, 0); 

ip[0] = outclass; /* class number */
ip[1] = 1;        /* only one buf */
ip[2] = 0;
ip[3] = 0;
ip[4] = 0;
nsem_take("fsctl",0);
skd_run("matcn",'w',ip);
nsem_put("fsctl");

/* get reply from matcn */
skd_par(ip);
inclass = ip[0];
if( ip[2] < 0 )
	{
	endwin();
	printf("Error %d from formatter\n",ip[2]);
        logita(NULL,ip[2],ip+3,ip+4);
	cls_clr(outclass);
	cls_clr(inclass);
        rte_sleep(SLEEP_TIME);
	exit(0);
	}

cls_clr(outclass); /* clear class numbers just in case */
cls_clr(inclass);

}
