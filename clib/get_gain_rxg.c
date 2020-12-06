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
#include <stdio.h>
#include <sys/types.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int get_gain_rxg(ifchain,lcl)
int ifchain;
struct lo_cmd *lcl;
{
  int ir, i;
  double lo;

  ir=-1;
  if(1 <= ifchain && ifchain <= MAX_LO) {
    lo=lcl->lo[ifchain-1];
  } else
    return ir;

  for(i=0;i<MAX_RXGAIN;i++) {
    if(shm_addr->rxgain[i].type=='f'
       && ((fabs(lo-shm_addr->rxgain[i].lo[0])
	    < 0.001)
	   ||(shm_addr->rxgain[i].lo[1] > 0.0
	      && fabs(lo-shm_addr->rxgain[i].lo[1])
	      < 0.001))
       ) {
      ir=i;
    }
  }
  if(ir==-1)
    for(i=0;i<MAX_RXGAIN;i++) {
      if(shm_addr->rxgain[i].type=='r'
	 && lo>shm_addr->rxgain[i].lo[0]-0.001
	 && lo<shm_addr->rxgain[i].lo[1]+0.001) {
	ir=i;
      }
    }
  return ir;
}
