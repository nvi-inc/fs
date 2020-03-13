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
#include <signal.h>
#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

double refrw();

int local(lonpos,latpos,axis,ierr)
     double *lonpos,*latpos;
     char *axis;
     int *ierr;
{
  int it[6];
  double az,el,x,y;

  rte_time(it,it+5);
  cnvrt2(1,shm_addr->radat,shm_addr->decdat,&az,&el,it,0.0,shm_addr->alat,
     shm_addr->wlong);

  el+=DEG2RAD*refrw(el,20.0,50.0,950.0);

  cnvrt2(5,az,el,&x,&y,it,0.0,shm_addr->alat,shm_addr->wlong);

  if(strcmp(axis,"azel")==0) {
    cnvrt2(4,x,y,lonpos,latpos,it,0.0,shm_addr->alat,shm_addr->wlong);
  } else if(strcmp(axis,"hadc")==0) {
    cnvrt2(6,x,y,lonpos,latpos,it,0.0,shm_addr->alat,shm_addr->wlong);
  } else if(strcmp(axis,"xyns")==0) {
    *lonpos=x;
    *latpos=y;
  } else {
    *ierr=-40;
    return -1;
  }
  return 0;
}
