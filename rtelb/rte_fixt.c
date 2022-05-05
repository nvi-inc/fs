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
/* rte_fixt.c - calculate offset to add to time */

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_fixt( poClock, plCentiSec)
//time_t *poClock;
int    *poClock;
int *plCentiSec;
{
  
  int iIndex;
  iIndex = 01 & shm_addr->time.index;

  if(shm_addr->time.model != 'n' && shm_addr->time.model != 'c' &&
     shm_addr->time.epoch[iIndex]!=0 && shm_addr->time.icomputer[iIndex]==0) {

        int lEpoch, lAddHs;

        lEpoch = shm_addr->time.epoch[iIndex];
	lAddHs = shm_addr->time.offset[iIndex];

     	if (lEpoch && shm_addr->time.model == 'r') {
                float fAdd;
       		fAdd = shm_addr->time.rate[iIndex] * (*plCentiSec-lEpoch);

		if((lAddHs+fAdd) >= 0.0)
		  lAddHs += (fAdd + 0.5);
		else
		  lAddHs += (fAdd - 0.5);
        }
        *plCentiSec += lAddHs;
     }

     if (*plCentiSec >= 0) { 
      *poClock = (*plCentiSec/100) + shm_addr->time.secs_off;
      *plCentiSec %= 100;
    } else {
      *poClock = ((*plCentiSec-99)/100) + shm_addr->time.secs_off;
      *plCentiSec = (100 + (*plCentiSec % 100)) %100;
    }

    return;
}
