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
/* setfile10gtime.c - set fila10g time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>
#include <string.h>
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "../include/params.h"

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
extern iDBBC;

void setfila10gtime(formtime,delta)
time_t formtime;
int delta;
{
struct tm *fmtime;  /* pointer to tm structure */
int count;
 char *name;

 struct tm *formtm;
 if(formtime < 0) {
   strcpy(outbuf,"fila10g=timesync");
 } else {
   formtime=formtime+delta;
   formtm=gmtime(&formtime);
   (void) strftime(outbuf,sizeof(outbuf),
		   "fila10g=timesync %Y-%m-%dT%H:%M:%S",formtm);
 }
 if(0==iDBBC)
   logit("FiLa10G time-set/sync command sent.",0,NULL);
 else if (1==iDBBC)
   logit("FiLa10G#1 time-set/sync command sent.",0,NULL);
 else
   logit("FiLa10G#2 time-set/sync command sent.",0,NULL);
 
 count=strlen(outbuf);		

/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, count, 0, 0); 

ip[0] = 6;        /*mode*/
ip[1] = outclass; /* class number */
ip[2] = 1;        /* only one buf */
ip[3] = 0;
ip[4] = 0;

 if(2!=iDBBC)
   name="dbbcn";
 else
   name="dbbc2";

nsem_take("fsctl",0);

	while(skd_run_to(name,'w',ip,200)==1) {
	  if (nsem_test(NSEM_NAME) != 1) {
	    endwin();
	    fprintf(stderr,"Field System not running - fmset aborting\n");
	    rte_sleep(SLEEP_TIME);
	    exit(0);
	  }
	  name=NULL;
	}

nsem_put("fsctl");

/* get reply from mk5cn */
skd_par(ip);

 if(ip[1]!=0)
   cls_clr(ip[0]);
 if( ip[2] < 0 )	{
   logita(NULL,ip[2],ip+3,ip+4);
   logit(NULL,-9,"fv");
 }

}
