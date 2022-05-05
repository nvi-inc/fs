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
     struct tms buffer;
     clock_t ticks;

     ticks=times(&buffer);

     if(ticks == -1) {
       logit(NULL,errno,"un");
       *iErr=-5;
     } else if(((unsigned int) ticks - shm_addr->time.ticks_off)
	     /(86400L*100*248) > 0)
       *iErr = -1;  /* already passed 248 days */
     else if(ticks > -1 && ticks < shm_addr->time.ticks_off)
       *iErr = -2;   /* already passed -1 */
     else if(((unsigned int) ticks - shm_addr->time.ticks_off)
	     /(86400L*100*219) > 0)
       *iErr = -3;  /* less than 30 days to go */
     else if(ticks < -1 && -ticks/(100*86400*30) < 1)
       *iErr = -4;  /* less than 30 days to -1 */
     else
       *iErr = 0;

     return;
}
     
