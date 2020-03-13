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
#include <stdlib.h>
#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int antcn(int ip[5])
{
  int ip0;

  if(0==strncmp(shm_addr->idevant,"/dev/null ",10)) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=-400;
    memcpy(ip+3,"q2",2);
    return;
  }

  ip0=ip[0];
  ip[2]=0;
  skd_run("antcn",'w',ip);

  if(ip[2] >= 0 && (ip0 == 1 || ip0 == 9)) {
    ip[0]=1;
    ip[2]=0;
    skd_run("flagr",'n',ip);
  }

}
