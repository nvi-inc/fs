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
/* mk5dbbcd_pfb.c make list of bbc detectors needed for DBBC_PFB rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk5dbbcd_pfb(itpis)
int itpis[MAX_DBBC_PFB];
{
  int vc,i;

  if(shm_addr->mk5b_mode.mask.state.known == 0 ||
     shm_addr->dbbcform.mode!=0)
    return;

  for(i=0;i<16;i++) {
    if(shm_addr->mk5b_mode.mask.mask & (0x3ULL << (i*2)) &&
       0 != shm_addr->dbbc_vsix[0].core[i])
      itpis[(shm_addr->dbbc_vsix[0].core[i]-1)*16+
	    shm_addr->dbbc_vsix[0].chan[i]] = 1;

    if(shm_addr->mk5b_mode.mask.mask & (0x3ULL << (32+i*2)) &&
       0 != shm_addr->dbbc_vsix[1].core[i]) {
      itpis[(shm_addr->dbbc_vsix[1].core[i]-1)*16+
	    shm_addr->dbbc_vsix[1].chan[i]] = 1;
    }
  }
}

