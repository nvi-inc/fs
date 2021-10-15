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
#include <stdlib.h>
#include <errno.h>

void get_rte_time__(it,it6)
int it[5],*it6;
{
     struct tm *ptr;
     time_t clock;
     struct timeval tv;

       if(0!= gettimeofday(&tv, NULL)) {
	 perror("getting timeofday, fatal\n");
	 exit(-1);
     }

     ptr=gmtime(&tv.tv_sec);
     it[0] = tv.tv_usec/10000;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     *it6=1900+ptr->tm_year;

     return;
}
