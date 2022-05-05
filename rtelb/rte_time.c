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
/* rte_time.c - return rte format time buffer */

#include <sys/types.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_rawt();
void rte_fixt();

void rte_time(it,it6)
int it[5],*it6;
{
     struct tm *ptr;
     time_t clock;
     int clock32;
     int centisec;

     rte_rawt(&centisec);  /* retrieve the raw time */

//     rte_fixt(&clock, &centisec);	/* correct for clock drift model */
     rte_fixt(&clock32, &centisec);	/* correct for clock drift model */
     clock=clock32;

     ptr=gmtime(&clock);            /* store in rte exec(11 time buffer */
     it[0] = centisec%100;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     *it6=1900+ptr->tm_year;

     return;
}
