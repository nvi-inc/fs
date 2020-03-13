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
/* secs_time.c - return rte time format from UNIX time  */

#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>
#include <time.h>

void secs_times(it,it6)
int it[5],it6;

{
     struct tm *ptr;
     time_t secs;
     struct timeval tv;

     if(0!= gettimeofday(&tv, NULL)) {
       perror("getting timeofday in secs_time, fatal\n");
       exit(-1);
     }
     secs=tv.tv_sec;

     ptr=gmtime(&secs);
                          /* store in rte exec(11 time buffer */

     it[0]=tv.tv_usec/10000;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     it6=1900+ptr->tm_year;

     return;
}
