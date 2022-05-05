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
/* set k3 formatter aux data for narrow track commands */

#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void set_k3aux(lauxfm,ip)
char lauxfm[12];
int ip[5];
{
  char buffer[20];
  int i;

  ip[0]=ip[1]=0;

  for(i=0;i<16;i++)
    lauxfm[i]=toupper(lauxfm[i]);

  strncpy(shm_addr->k3fm.aux,lauxfm,12);
  strcpy(buffer,"AUX=");
  strncat(buffer,lauxfm,12);
  buffer[16]=0;
  ib_req2(ip,"f3",buffer);

  skd_run("ibcon",'w',ip);
  skd_par(ip);

}






