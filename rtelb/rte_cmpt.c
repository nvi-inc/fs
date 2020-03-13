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
/* rte_cmpt.c - calculate computer time */

#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_cmpt( poClock, plCentiSec)
//time_t *poClock;
int    *poClock;
int *plCentiSec;
{
     struct timeval tv;
     int lRawTime;

     if(0!= gettimeofday(&tv, NULL)) {
       perror("getting timeofday, fatal\n");
       exit(-1);
     }
     *poClock=tv.tv_sec;
     *plCentiSec=tv.tv_usec/10000;
     if(*plCentiSec>99) {
       *plCentiSec-=100;
       (*poClock)++;
     }

     return;
}
