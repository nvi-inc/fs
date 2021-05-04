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
#include <signal.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include <unistd.h>

clock_t rte_times(struct tms *buf);

unsigned rte_sleep( centisec)
unsigned centisec;
{
     struct tms buffer;
     unsigned int wait, end, now;
     unsigned int usecs;

     end=rte_times(&buffer)+centisec+1;

     now=rte_times(&buffer);
     while(end > now) {
       wait=end-now;
       if(wait>429496) /* max unsigned we can multiple up to fit */
         wait=429496;
       usecs=wait*10000;
       usleep(usecs);
       now=rte_times(&buffer);
     }

     return( (unsigned) 0);
}
