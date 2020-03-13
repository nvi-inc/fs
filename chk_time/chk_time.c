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
#include <stdio.h>
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>

/*
 * Compare systems times to system time, this might detect steps in NTP
 */
main(int argc, char *argv[])
{

  struct tms buffer;
  struct timeval tv0, tv;

  clock_t ticks;
  unsigned int ticks0, ticks_diff, ticks0_save;
  int first=1;
  
  while(first || ticks0!=ticks0_save) {
    first=0;
    ticks=times(&buffer);
    if(ticks == (clock_t) -1) {
      perror("using times() initially");
      exit(-1);
    }
    ticks0_save=ticks0;
    ticks0=ticks;
    
    if(0!= gettimeofday(&tv0, NULL)) {
      perror("using getttimeofday() initially");
      exit(-1);
    }
  }

  for (;;) {
    ticks=times(&buffer);
    if(ticks == (clock_t) -1) {
      perror("using times()");
      exit(-1);
    }

    if(0!= gettimeofday(&tv, NULL)) {
      perror("using getttimeofday()");
      exit(-1);
    }

    if(0==
       (((tv.tv_sec-tv0.tv_sec)*1000000ll+(tv.tv_usec-tv0.tv_usec))/1000)%1000) {

    printf("%llu %u %llu\n",
	   ((tv.tv_sec-tv0.tv_sec)*1000000ll+(tv.tv_usec-tv0.tv_usec))/1000,
	   (unsigned int)ticks-ticks0,
	   ((unsigned int)ticks-ticks0)-
	   (((tv.tv_sec-tv0.tv_sec)*1000000ll+(tv.tv_usec-tv0.tv_usec))/10000)
	   );
    fflush(stdout);
    }
    if(0!= usleep(1000)) {
      perror("using usleep");
      exit(-1);
    }
  }
}
