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
/* vlbabbcd.c make list of bbc detectors needed for VLBA rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vlbabbcd(itpis)
int itpis[2*MAX_BBC];
{
  int i;
  static int kfirst = TRUE;
  static char *type;

  if (kfirst) {
    if(shm_addr->equip.rack_type == VLBA)
      type="vlba";
    else if(shm_addr->equip.rack_type == VLBAG)
      type="vlbag";
    else
      type="";
    kfirst=FALSE;
  }  

  if(strlen(type)==0)
    return;

  for (i=0;i<32;i++) {
    int det;
    det=code2det(shm_addr->vform.codes[i],type);
    if(det<0)
      itpis[-1-det]=1;
    else if (det>0)
      itpis[MAX_BBC-1+det]=1;
  }
}
