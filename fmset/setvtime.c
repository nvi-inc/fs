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
/* setvtime.c - set vlba formmatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <errno.h>       /* error code definition header file */
#include <memory.h>      /* for memcpy */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "fmset.h"

extern unsigned char inbuf[512];      /* class i-o buffer */
extern unsigned char outbuf[512];     /* class i-o buffer */
extern char setcmd[];
extern int inclass;         /* input class number */
extern int outclass;        /* output class number */
extern int ip[5];           /* parameters for fs communications */
extern int rtn1, rtn2, msgflg, save; /* unused cls_get args */

void skd_run();
void skd_par();
void cls_snd();
int cls_rcv();
void cls_clr();

void setvtime(formtime)
time_t formtime;
{
struct tm *fmtime;  /* pointer to tm structure */
int i;              /* general purpose counter */
int nbytes;         /* number of bytes received from mcbcn */
unsigned short bcd; /* holder for BCD digits   */
 char *name; 

/* convert calendar time to conventional time */
fmtime = gmtime(&formtime);

for (i = 0; i < 28; i++)  /* get set time message */
	{
	outbuf[i] = (unsigned char) setcmd[i];
	}

fmtime->tm_year += 1900;  /* gmtime returns years since 1900 */
bcd = 0;
for (i = 1000; i; i /= 10)
	{
	bcd = (bcd << 4) + fmtime->tm_year / i;
	fmtime->tm_year = fmtime->tm_year % i;
	}
memcpy(outbuf+5,&bcd,2);
swab(outbuf+5,outbuf+5,2);

/* stuff address & BCD day # into message */
fmtime->tm_yday += 1;  /* gmtime returns days since 1 january */
bcd = 0;
for (i = 100; i; i /= 10)
	{
	bcd = (bcd << 4) + fmtime->tm_yday / i;
	fmtime->tm_yday = fmtime->tm_yday % i;
	}
memcpy(outbuf+12,&bcd,2);
swab(outbuf+12,outbuf+12,2);

/* stuff address & BCD hour into message */
bcd = fmtime->tm_hour / 10 << 4 | fmtime->tm_hour % 10;
memcpy(outbuf+19,&bcd,2);
swab(outbuf+19,outbuf+19,2);

/* stuff address & BCD minute-second into message */
bcd = fmtime->tm_min / 10 << 12 |
      fmtime->tm_min % 10 << 8  |
      fmtime->tm_sec / 10 << 4  |
      fmtime->tm_sec % 10;
memcpy(outbuf+26,&bcd,2);
swab(outbuf+26,outbuf+26,2);

/* send request buffer to MCB */
/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, 28, 0, 0); 

ip[0] = 1;        /* process command buf */
ip[1] = outclass; /* class number */
ip[2] = 1;        /* only one buf */
ip[3] = 0;
ip[4] = 0;
name="mcbcn";
nsem_take("fsctl",0);
	while(skd_run_to(name,'w',ip,100)==1) {
	  if (nsem_test(NSEM_NAME) != 1) {
	    endwin();
	    fprintf(stderr,"Field System not running - fmset aborting\n");
	    exit(0);
	  }
	  name=NULL;
	}
nsem_put("fsctl");

/* get reply from mcbcn */
ip[0] = ip[1] = ip[2] = ip[3] = ip[4] = 0;
skd_par(ip);
inclass = ip[0];
if( ip[1] != 1 )
	{
	endwin();
	fprintf(stderr,"Error %d from formatter\n",ip[2]);
        logita(NULL,ip[2],ip+3,ip+4);
	cls_clr(outclass);
	cls_clr(inclass);
        rte_sleep( SLEEP_TIME);
	exit(0);
	}
msgflg = save = 0;
if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                       &rtn1, &rtn2, msgflg, save)) != 4)
	{
	endwin();
	fprintf(stderr,"Wrong len msg - %d bytes received\n" ,nbytes);
        logita(NULL,-4,"fv","  ");
	cls_clr(outclass);
	cls_clr(inclass);
        rte_sleep( SLEEP_TIME);
	exit(0);
	}

if( inbuf[0] | inbuf[1] | inbuf[2] | inbuf[3] ) /* check completion code */
	{
	endwin();
	fprintf(stderr,"Bad completion code from formatter %d %d %d %d\n",
               inbuf[0],inbuf[1],inbuf[2],inbuf[3]);
        logita(NULL,-5,"fv","  ");
	cls_clr(outclass);
	cls_clr(inclass);
        rte_sleep( SLEEP_TIME);
	exit(0);
	}

cls_clr(outclass); /* clear class numbers just in case */
cls_clr(inclass);

}
