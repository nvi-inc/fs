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
#include <string.h>
#include <stdio.h>

#include <math.h>
#include "../include/dpi.h"    /* FS pi conversions        */
#include "../include/params.h" /* FS parameters            */
#include "../include/fs_types.h" /* FS header files        */
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int satpos(itcmd,azcmd,elcmd)
     int itcmd[6];
     double *azcmd,*elcmd;
{
  int i, iret;
  int seconds;

  iret=0;

  rte2secs(itcmd,&seconds);
  seconds=rint(seconds+itcmd[0]/100.0+shm_addr->satoff.seconds);
  if(seconds < shm_addr->ephem[0].t) {
    *azcmd=shm_addr->ephem[0].az;
    *elcmd=shm_addr->ephem[0].el;
    iret=-1;
  }  else if(seconds >= shm_addr->ephem[MAX_EPHEM-1].t) {
    *azcmd=shm_addr->ephem[MAX_EPHEM-1].az;
    *elcmd=shm_addr->ephem[MAX_EPHEM-1].el;
    iret=+1;
  }  else  {
    for (i=0;i<MAX_EPHEM;i++)
      if(seconds == shm_addr->ephem[i].t) {
	*azcmd=shm_addr->ephem[i].az;
	*elcmd=shm_addr->ephem[i].el;
	break;
      }
    if(i==MAX_EPHEM) {
      *azcmd=shm_addr->ephem[MAX_EPHEM-1].az;
      *elcmd=shm_addr->ephem[MAX_EPHEM-1].el;
      iret=+1;
    }
  }
  /*  printf(" i %d az %.3f el %.3f\n",i,*azcmd*RAD2DEG,*elcmd*RAD2DEG);  */

}
