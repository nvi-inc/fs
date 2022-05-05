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
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void rte_time(it,it6)
int it[5],*it6;
{
     struct tm *ptr;
     time_t clock1, clock2;
     int times();
     struct tms buffer;
     int centisec;

     clock1=time(&clock1);
     centisec=times(&buffer);
     clock2=time(&clock2);
     if(clock2 != clock1) centisec=0; else centisec=(centisec-1)%100;
     ptr=gmtime(&clock2);

     it[0]=centisec;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     *it6=1900+ptr->tm_year;

     return;
}
