/*
 * Copyright (c) 2020, 2026 NVI, Inc.
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
/* rte_ticks.c - return raw system ticks in clock HZ */
/*              used when when only approximate relative time is needeed */


#include <stdlib.h>
#include <sys/times.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_ticks(lRawTicks)
int *lRawTicks;
{
    int iIndex;
    iIndex = 01 & shm_addr->time.index;

    if(shm_addr->time.model != 'n' && shm_addr->time.model != 'c' &&
            shm_addr->time.epoch[iIndex]!=0 && shm_addr->time.icomputer[iIndex]==0) {

        struct timespec tvt;
        if(0!= clock_gettime(CLOCK_MONOTONIC,&tvt)) {
            perror("rte_ticks, using clock_getttime(), fatal");
            exit(-1);
        }
        /* limit about 248.55 days */
        *lRawTicks=(tvt.tv_sec-shm_addr->time.ticks_off)*100+
            +tvt.tv_nsec/10000000;
//            printf("tvt.tv_sec %d ticks_off %d diff %d raw %d\n",
//            tvt.tv_sec,shm_addr->time.ticks_off,tvt.tv_sec-shm_addr->time.ticks_off,*lRawTicks);
    }  else {

        struct timeval tv;
        if(0!= gettimeofday(&tv, NULL)) {
            perror("rte_ticks, using gettimeofday(), fatal\n");
            exit(-1);
        }
        /* limit about 248.55 days */
        *lRawTicks=(tv.tv_sec-shm_addr->time.secs_off)*100+
            +tv.tv_usec/10000;
//            printf("tv.tv_sec %d secs_off %d diff %d raw %d\n",
//            tv.tv_sec,shm_addr->time.secs_off,tv.tv_sec-shm_addr->time.secs_off,*lRawTicks);
    }
  return;
}
