/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* set4time.c - set mk4 formatter time */

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
extern int inclass;         /* input class number */
extern int outclass;        /* output class number */
extern int ip[5];           /* parameters for fs communications */
extern int rtn1, rtn2, msgflg, save; /* unused cls_get args */

void set4time(formtime,delta)
time_t formtime;
int delta;
{
struct tm *fmtime;  /* pointer to tm structure */
short sh9={9};
int count;
 char *name;

	memcpy(outbuf,&sh9,2);

	if(delta == 0) {
		unsigned char *cp;
                struct tm *formtm;
                formtm=gmtime(&formtime);
		(void) strftime(outbuf+2,sizeof(outbuf)-2,
                                "fm/tim %Y %j %H %M %S",formtm);
		for (cp=outbuf+2;*(cp+2)!=0;cp++)
			if(*cp==' '&&*(cp+1)=='0' && *(cp+2)!=' ')
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
 name="matcn";
nsem_take("fsctl",0);

	while(skd_run_to(name,'w',ip,100)==1) {
	  if (nsem_test(NSEM_NAME) != 1) {
	    endwin();
	    fprintf(stderr,"Field System not running - fmset aborting\n");
	    rte_sleep(SLEEP_TIME);
	    exit(0);
	  }
	  name=NULL;
	}

nsem_put("fsctl");

/* get reply from matcn */
skd_par(ip);
 if(ip[1]!=0)
   cls_clr(ip[0]);
if( ip[2] < 0 )	{
  logita(NULL,ip[2],ip+3,ip+4);
  logit(NULL,-10,"fv");
 }

}
