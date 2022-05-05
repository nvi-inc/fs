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
/* rte_rawt.c - return raw system time in clock HZ */

#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_rawt(lRawTime)
int *lRawTime;
{
     struct tms buffer;
     struct timeval tv;
     int index;

     index=01 & shm_addr->time.index;
     if(shm_addr->time.model!='c'
	&& shm_addr->time.epoch[index]!=0
	&& shm_addr->time.icomputer[index]==0 ) {
       rte_ticks(lRawTime);
     } else {
       if(0!= gettimeofday(&tv, NULL)) {
	 perror("getting timeofday, fatal\n");
	 exit(-1);
       }
       *lRawTime=(tv.tv_sec-shm_addr->time.secs_off)*100
	 +tv.tv_usec/10000;
     }

     return;
}
