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
/* setfmtime.c - set formatter time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>
#include "../include/params.h"

#include "fmset.h"

void setvtime();
void set4time();

extern int rack;
extern int rack_type;
extern int source;
extern int s2type;
extern char s2dev[2][3];
extern int iRDBE;

void setfmtime(formtime,delta,vdif_epoch)
time_t formtime;
int delta;
int vdif_epoch;
{

if (nsem_test(NSEM_NAME) != 1) {
  endwin();
  fprintf(stderr,"Field System not running - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
}
  if (source == RDBE) 
    setRDBEtime(formtime,delta,vdif_epoch);
  else if (source == MK5 )
    set5btime(formtime,delta);
  else if (source == DBBC
  /* was:
   * rack == DBBC && (rack_type == DBBC_DDC_FILA10G || rack_type == DBBC_PFB_FILA10G) */
	   )
    setfila10gtime(formtime,delta);
  else if (source == S2)
    sets2time(s2dev[s2type],formtime+delta);
  else if (rack & VLBA)
    setvtime((time_t) (formtime + delta));
  else
    set4time(formtime,delta);

}
