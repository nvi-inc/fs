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
/* getfmtime.c - get formatter time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "fmset.h"

void getvtime();
void get4time();
extern int rack;
extern rack_type;
extern int source;
extern int s2type;
extern char s2dev[2][3];

void getfmtime(unixtime,unixhs,fstime,fshs,formtime,formhs,m5sync,sz_m5sync,
	       m5pps,sz_m5pps,m5freq,sz_m5freq,m5clock,sz_m5clock,vdif_epoch,ierr)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time */
int    *formhs;
char *m5sync;
int sz_m5sync;
char *m5pps;
int sz_m5pps;
char *m5freq;
int sz_m5freq;
char *m5clock;
int sz_m5clock;
int *vdif_epoch;
int *ierr;
{
  static int phase =-1;
  int raw, sleep, rawch;
  int it[6];

  *ierr=0;

  if (nsem_test(NSEM_NAME) != 1) {
    endwin();
    fprintf(stderr,"Field System not running - fmset aborting\n");
    rte_sleep(SLEEP_TIME);
    exit(0);
  }

  if (source == RDBE) {
    rte_sleep(10);
    rte_ticks(&raw);
    if(phase != -2) {
      sleep=102-(raw%100+phase)%100;
    } else
      sleep=101;
    if(sleep >=0) {
      rte_sleep(sleep); 
    }
    getRDBEtime(unixtime,unixhs,fstime,fshs,formtime,formhs,&rawch,vdif_epoch);
    if(*formtime < 0) {
      phase = -2;
    } else if(*formhs > -1 && *formhs < 100) {
      phase=(100+*formhs-rawch%100)%100;
    }
  } else if (source == MK5) {
    rte_sleep(10);
    rte_ticks(&raw);
    if(phase != -2) {
      sleep=102-(raw%100+phase)%100;
    } else
      sleep=101;
    if(sleep >=0) {
      rte_sleep(sleep); 
    }
    get5btime(unixtime,unixhs,fstime,fshs,formtime,formhs,&rawch,m5sync,
	      sz_m5sync,m5pps,sz_m5pps,m5freq,sz_m5freq,m5clock,sz_m5clock,
	      ierr);
    if(*formtime < 0) {
      phase = -2;
    } else if(*formhs > -1 && *formhs < 100) {
      phase=(100+*formhs-rawch%100)%100;
    }
  } else if (source == DBBC 
   /* was:
    * rack == DBBC && (rack_type == DBBC_DDC_FILA10G || rack_type == DBBC_PFB_FILA10G) */
	     ) {
    getfila10gtime(unixtime,unixhs,fstime,fshs,formtime,formhs);
  }  else if (source == S2) {
    gets2time(s2dev[s2type],unixtime,unixhs,fstime,fshs,formtime,formhs);
  } else if(rack&VLBA)
      getvtime(unixtime,unixhs,fstime,fshs,formtime,formhs);
  else {
    rte_sleep(10);
    rte_ticks(&raw);
    sleep=102-(raw%100+phase)%100;
    if(sleep >=0) {
      rte_sleep(sleep); 
    }
    get4time(unixtime,unixhs,fstime,fshs,formtime,formhs,&rawch);
    if(*formtime < 0) {
      phase = -2;
    } else if(*formhs > -1 && *formhs < 100) {
      phase=(100+*formhs-rawch%100)%100;
    }
  }
}

