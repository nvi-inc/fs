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

#include "sample_ds.h"

int gooff(lonoff,latoff,axis,nwait,ierr)
     double lonoff,latoff;
     char *axis;
     int nwait,*ierr;
{

  if(strcmp(axis,"azel")==0) {
    shm_addr->AZOFF=lonoff;
    shm_addr->ELOFF=latoff;
  } else if(strcmp(axis,"hadc")==0) {
    shm_addr->RAOFF=-lonoff;
    shm_addr->DECOFF=latoff;
  } else if(strcmp(axis,"xyns")==0||strcmp(axis,"xyew")==0) {
    shm_addr->XOFF=lonoff;
    shm_addr->YOFF=latoff;
  } else {
    *ierr=-60;
    return -1;
  }

  if(antcn(2,ierr))
    return -1;

  if(onsor(nwait,ierr))
    return -1;

  return 0;
}
