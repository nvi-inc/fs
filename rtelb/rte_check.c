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
/* rte_check_ticks.c - check for possible errors in ticks usage */

#include <stdlib.h>
#include <sys/times.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_check(iErr)
int *iErr;
{
    int iIndex;
    iIndex = 01 & shm_addr->time.index;

    *iErr=0;

    if(shm_addr->time.model != 'n' && shm_addr->time.model != 'c' &&
            shm_addr->time.epoch[iIndex]!=0 && shm_addr->time.icomputer[iIndex]==0) {
        struct timespec tvt;
        if(0!= clock_gettime(CLOCK_MONOTONIC,&tvt)) {
            perror("rte_check, using clock_getttime()");
            *iErr=-5;
            return;
        }
        /* limit about 248.55 days */
        int diff=tvt.tv_sec-shm_addr->time.ticks_off;
        if(diff>=248*86400)
            *iErr=-1;
        else if(diff>=218*86400)
            *iErr=-2;

    }  else {
        struct timeval tv;
        if(0!= gettimeofday(&tv, NULL)) {
            perror("rte_check, using gettimeofday()");
            *iErr=-7;
            return;
        }
        /* limit about 248.55 days */
        int diff=tv.tv_sec-shm_addr->time.secs_off;
        if(diff>=248*86400)
            *iErr=-3;
        else if(diff <=-248*86400)
            *iErr=-4;
        else if(diff>=218*86400)
            *iErr=-6;
    }
    return;
}
