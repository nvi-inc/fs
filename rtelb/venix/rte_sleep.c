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
#include <rtx.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

unsigned rtsleep();
int rte_alarm();
void pause();

unsigned rte_sleep( centisec)
unsigned centisec;
{
     int times();
     struct tms buffer;
     int now, end;
     unsigned iret;
     int time,wait;

     end=times(&buffer)+centisec;

/* detect lack of permission by checking granularity */

    if(-1==rtalarm(RT_ALARM_GETGRAN,time,SIGALRM)) {
      perror("rte_sleep, getting granularity");
      exit(-1);
   }
     wait=end-times(&buffer);        /* must be a signed int for comparison */
     while(wait>0) {
       iret=rtsleep((unsigned) wait*10);
       wait=end-times(&buffer);
     }

     rte_fpmask();     /* re-disable fp exceptions after sleep re-enables */
     return( (unsigned) 0);
}
