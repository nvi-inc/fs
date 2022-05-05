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
/* gets2time.c - get s2 recorder time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "fmset.h"

extern int ip[5];           /* parameters for fs communications */
extern int nanosec;

void rte2secs();

void gets2time(dev,unixtime,unixhs,fstime,fshs,formtime,formhs)
char dev[];
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
{
  int centisec[6], centiavg, centidiff;
  int it[6], icount;
  int formtime32;
  int fstime32;

  icount=0;
try:	
  nsem_take("fsctl",0);
  if(get_s2time(dev,centisec,it,&nanosec,ip,1)!=0) {
    endwin();
    fprintf(stderr,"Field System not running - fmset aborting\n");
    exit(0);
  }
  nsem_put("fsctl");
  if( ip[2] < 0) {
    if(ip[2]< -400 && ip[2] > -404)
      memcpy(ip+3,"fv",2);
    logita(NULL,ip[2],ip+3,ip+4);
    cls_clr(ip[0]);
    if(ip[2]==-133 && ++icount < 3)
      goto try;
    
    endwin();
    fprintf(stderr,"Error %d from formatter\n",ip[2]);
    logita(NULL,ip[2],ip+3,ip+4);
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  
  centiavg= centisec[1]; /* for S2 second time is much more accurate */
  
  *unixtime=centisec[3];
  *unixhs=centisec[5];
  
//  rte_fixt(fstime,&centiavg);
  rte_fixt(&fstime32,&centiavg);
  *fstime=fstime32;
  *fshs=centiavg;
  
//  rte2secs(it,formtime);
  rte2secs(it,&formtime32);
  *formtime=formtime32;
  *formhs=0;
}
