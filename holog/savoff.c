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

savoff(xoff,yoff,azoff,eloff,haoff,decoff)
double *xoff,*yoff,*azoff,*eloff,*haoff,*decoff;
{

  *xoff=shm_addr->XOFF;
  *yoff=shm_addr->YOFF;
  *azoff=shm_addr->AZOFF;
  *eloff=shm_addr->ELOFF;
  *haoff=-shm_addr->RAOFF;
  if(*haoff==-0.0)
    *haoff=0.0;
  *decoff=shm_addr->DECOFF;

}
