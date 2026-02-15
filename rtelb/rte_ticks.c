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
/*               used when rte_fixt() will be used aftrerwards to get the real time */

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
     struct tms buffer;
     clock_t ticks;

     int index=01 & shm_addr->time.index;
     if(shm_addr->time.model!='c'
             && shm_addr->time.epoch[index]!=0
             && shm_addr->time.icomputer[index]==0 ) {
         ticks=times(&buffer);
         if(ticks == (clock_t) -1) {
             perror("using times()");
             exit(-1);
         }
         *lRawTicks=(signed) ((unsigned int) ticks - shm_addr->time.ticks_off);
     } else {
        struct timeval tv;
         if(0!= gettimeofday(&tv, NULL)) {
             perror("getting timeofday, fatal\n");
             exit(-1);
         }
         *lRawTicks=(tv.tv_sec-shm_addr->time.secs_off)*100+
             +tv.tv_usec/10000;
     }

     return;
}
