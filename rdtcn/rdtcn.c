/*
 * Copyright (c) 2020, 2022, 2023, 2025 NVI, Inc.
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
/* Receiver/client multicast Datagram example. */
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <errno.h>
#include <math.h>

#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define TO_CENTISECONDS  420

extern struct fscom *shm_addr;

double rdbe_freqz(double);

int main(int argc, char *argv[])
{
  int ip[5];
  char who[ ]="cn";
  char me[]="rdtcn" ; /* My name */
  char letter;
  int irdbe;
  int i;
  char lets[]="abcdefghijklm";

  setup_ids();    /* attach to the shared memory */
  rte_prior(FS_PRIOR);

  if(argc >= 2) {
    memcpy(me+3,argv[1],2);
    memcpy(who,argv[1],2);
    letter=me[4];
  }
  putpname(me);

  while(1) { /* we loop back here if there was an error initializing */
    skd_wait(me,ip,(unsigned) 0);

    irdbe=-1;
    for(i=0;i<MAX_RDBE;i++)
      if(me[4]==lets[i])
        if(0!=shm_addr->rdbehost[i][0]) {
          irdbe=i;
          break;
        } else
          logita(NULL,-3,"rz",who);
    if(irdbe < 0)
      continue;

    if(shm_addr->equip.rack == RDBE && shm_addr->equip.rack_type == RDBE)
      r1dbe(me, who, letter, irdbe);
    else if(shm_addr->equip.rack == RDBE && shm_addr->equip.rack_type == R2DBE)
      r2dbe(me, who, letter, irdbe);
    else
      logita(NULL,-4,"rz",who);
  }
}
