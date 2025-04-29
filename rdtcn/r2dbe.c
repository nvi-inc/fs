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

#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

int r2dbe(char me[5], char who[2], char letter, int irdbe)
{
    char buf[33960];
    int ip[5];

    int error_no;
    int sock = open_mcast(shm_addr->rdbad[irdbe].mcast_addr,
            shm_addr->rdbad[irdbe].mcast_port,
            shm_addr->rdbad[irdbe].mcast_if,
            &error_no);

    if(0>sock) {
        logitn(NULL,-10+sock,"xx",error_no);
        goto idle;
    }

    for (;;) {
      ssize_t n = read_mcast(sock,buf,sizeof(buf));

      printf(" me '%5s' n %d\n",me, n);
      if(n<0)
        continue;
    }

idle:
    for (;;)
        skd_wait(me,ip,(unsigned) 0);
}
