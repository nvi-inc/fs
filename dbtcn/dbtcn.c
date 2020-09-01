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

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define TO_CENTISECONDS  420

extern struct fscom *shm_addr;

static char me[]="dbtcn";

int main(int argc, char *argv[])
{
  int ip[5];

  setup_ids();    /* attach to the shared memory */
  rte_prior(FS_PRIOR);

  putpname("dbtcn");

  printf(" running %s\n",me);

  skd_wait(me,ip,(unsigned) 0);

  printf(" me %s\n",me);
  printf(" host %s\n",shm_addr->dbbad.host);
  printf(" port %d\n",shm_addr->dbbad.port);
  printf(" time_out %d\n",shm_addr->dbbad.time_out);
  printf(" mcast_addr %s\n",shm_addr->dbbad.mcast_addr);
  printf(" mcast_port %d\n",shm_addr->dbbad.mcast_port);
  printf(" mcast_if %s\n",shm_addr->dbbad.mcast_if);
  printf(" me %s done\n",me);

  for(;;)
      rte_sleep(100);

}
