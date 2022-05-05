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

#include "../include/params.h"        /* general fs parameter header */
#include "../include/fs_types.h"

#include "../rclco/rcl/rcl_def.h"

#include "fmset.h"

extern int ip[5];           /* parameters for fs communications */
extern int nanosec;

void skd_run();
void skd_par();
void cls_snd();
int cls_rcv();
void cls_clr();

void sets2time(dev,formtime)
char dev[];
time_t formtime;
{
  struct tm *fmtime;  /* pointer to tm structure */
  int ierr;
  struct rclcn_req_buf reqbuf;
  struct rclcn_res_buf resbuf;
  int year, day, hour, min, sec;
  ibool relative;
  int dnanosec;
  char *name;

  time_t unixtime; /* computer time */
  int    unixhs;
  time_t fstime; /* field system time */
  int    fshs;
  time_t formtime2; /* formatter time received from mcbcn */
  int    formhs;
  int before,after;

  if(nanosec==0)
    goto set;

  rte_rawt(&before);
  ini_rclcn_req(&reqbuf);

  relative=FALSE;
  dnanosec=0;
  add_rclcn_delay_set(&reqbuf,dev,relative,dnanosec);

  end_rclcn_req(ip,&reqbuf);

  name="rclcn";
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

  skd_par(ip);
  if( ip[2] < 0 )	{
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    if(ip[2]==-39)
      goto set;
    endwin();
    fprintf(stderr,"Error reply from rclcn - error %d\n", ip[2] );
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  opn_rclcn_res(&resbuf,ip);

  ierr=get_rclcn_delay_set(&resbuf);
  if(ierr!=0) {
    endwin();
    fprintf(stderr,"Error getting rclcn response - error %d\n", ierr );
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    rte_sleep(SLEEP_TIME);
    exit(0);
  }

  clr_rclcn_res(&resbuf);

  gets2time(&unixtime,&unixhs,&fstime,&fshs,&formtime2,&formhs);

  rte_rawt(&after);

  formtime+=(after-before+50)/100;

set:
  ini_rclcn_req(&reqbuf);
  
  /* convert calendar time to conventional time */

  fmtime = gmtime(&formtime);

  fmtime->tm_year += 1900;  /* gmtime returns years since 1900 */
  fmtime->tm_yday += 1;  /* gmtime returns days since 1 january */

  year=fmtime->tm_year;
  day =fmtime->tm_yday;
  hour=fmtime->tm_hour;
  min =fmtime->tm_min;
  sec =fmtime->tm_sec;
  add_rclcn_time_set(&reqbuf,dev,year,day,hour,min,sec);

  end_rclcn_req(ip,&reqbuf);

  name="rclcn";
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

  skd_par(ip);
  if( ip[2] < 0 ) {
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    if(ip[2]==-133)
      return;
    endwin();
    fprintf(stderr,"Error reply from rclcn - error %d\n", ip[2] );
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  opn_rclcn_res(&resbuf,ip);

  ierr=get_rclcn_time_set(&resbuf);
  if(ierr!=0) {
    endwin();
    fprintf(stderr,"Error getting rclcn response - error %d\n", ierr );
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  clr_rclcn_res(&resbuf);


}
