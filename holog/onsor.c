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

int onsor(nwait,ierr)
     int nwait,*ierr;
{

  int it[6];
  double tim,tim2;

  rte_time(it,it+5);
  tim=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;

  rte_time(it,it+5);
  tim2=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
  if(tim2<tim)
    tim2+=86400.0;

  while(tim+nwait>tim2) {
    if(antcn(5,ierr))
      return -1;

    if(shm_addr->ionsor!=0)
      return 0;

    rte_time(it,it+5);
    tim2=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
    if(tim2<tim)
      tim2+=86400.0;
  }

  *ierr=-20;
  return -1;
}
