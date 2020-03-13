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
#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>

int rtalarm();

unsigned rte_alarm( centisec)
unsigned centisec;
{
    int time;
    struct itimerval value;

    time=centisec;
    if(0>(int)centisec) /* correct for unsigned overflows so we at least
                           won't abend */
        time=((unsigned) ~0)>>1;

    value.it_interval.tv_sec=0L;
    value.it_interval.tv_usec=0L;
    value.it_value.tv_sec=(int) (time/100);
    value.it_value.tv_usec=(int) ((time%100)*10000);

    if(-1==setitimer(ITIMER_REAL,&value,0)) {
      perror("rte_alarm");
      printf("rte_alarm: error setting alarm, time %d\n",time);
      exit(-1);
    }
    return(0);
}
