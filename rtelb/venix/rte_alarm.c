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

int rtalarm();

unsigned rte_alarm( centisec)
unsigned centisec;
{
    int time, gran;

    if(centisec==0) {
      if(-1==rtalarm(RT_ALARM_CANCEL,time,SIGALRM)) {
        perror("rte_alarm, canceling");
        exit(-1);
      }
      return( 0);
    }

/* fetch granularity in micro-seconds */

    if(-1==(gran=rtalarm(RT_ALARM_GETGRAN,time,SIGALRM))) {
      perror("rte_alarm, getting granularity");
      exit(-1);
   }
   if(gran != 10000) {
      perror("rte_alarm, granularity != 10000");
      exit(-1);
   }

     time=centisec;
     if(0>(int)centisec) /* correct for unsigned overflows so we at least
                           won't abend */
        time=((unsigned) ~0)>>1;

    if(-1==rtalarm(RT_ALARM_ONCE,time,SIGALRM)) {
      perror("rte_alarm, setting alarm");
      printf(" RT_ %d time %d SIG %d\n",RT_ALARM_ONCE,time,SIGALRM);
      exit(-1);
    }
    return(0);
}
