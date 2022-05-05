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
/* mk5cd.c make list of vc detectors needed for mk5 rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk5vcd(itpis)
int itpis[14];
{
  int vc,i;

  if(shm_addr->mk5b_mode.mask.state.known == 0)
    return;

  if(shm_addr->vsi4.config.value == 0 ) { /*vlba */
    for (i=0;i<16;i++) {
      if((shm_addr->mk5b_mode.mask.mask & (1<<i)) ||
	 (shm_addr->mk5b_mode.mask.mask & (1<<(i+16)))) {
	vc=i/2;
	if(-1 < vc && vc <14)
	  itpis[vc]=1;
      }
    }
  } else if(shm_addr->vsi4.config.value == 1 ) { /*geo */
    for (i=0;i<16;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=i/2;
	if(-1 < vc && vc <14)
	  itpis[vc]=1;
      }
    }
    for (i=16;i<18;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=0;
	if(-1 < vc && vc <14)
	  itpis[vc]=1;
      }
    }
    for (i=18;i<20;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=7;
	if(-1 < vc && vc <14)
	  itpis[vc]=1;
      }
    }
    for (i=20;i<31;i++) {
      if(shm_addr->mk5b_mode.mask.mask & (1<<i)) {
	vc=(i-20)/2+8;
	if(-1 < vc && vc <14)
	  itpis[vc]=1;
      }
    }
  }
}
