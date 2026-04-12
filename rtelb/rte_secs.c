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
/* rte_secs.c - find seconds offset from times value */

#include <sys/times.h>
#include <sys/time.h>
#include <time.h>
#include <errno.h>

int rte_secs(int *usec_off,unsigned int *ticks_off,int *error, int *perrno)
{
  struct tms buf;
  struct timeval tv;
  clock_t ticks;

  ticks=times(&buf);
  if(ticks == (clock_t) -1) {
    perror("rte_secs, using times()");
    *error = -1;
    *perrno=errno;
    return 0;
  }

  if(0!= gettimeofday(&tv, NULL)) {
    perror("rte_secs, using gettimeofday()");
    *error = -2;
    *perrno=errno;
    return 0;
  }

  *error=0;
  *perrno=0;
  *ticks_off=(unsigned int) ticks;
  *usec_off=tv.tv_usec;
  return tv.tv_sec;

}
