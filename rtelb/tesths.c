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
#include <sys/time.h>
#include <unistd.h>

main()
{
  time_t clock1, clock2, clock1_old, clock2_old;
     struct timeval tv;
     int times();
     struct tms buffer;
     int lRawTime,lRawTime_old, tv_sec_old;

     clock1=0;
     clock2=1;
     while(1){
	clock1=time(&clock1);       /* bracket the centi-seconds */
        lRawTime=times(&buffer);
	if(0!= gettimeofday(&tv, NULL)) {
	  perror("getting timeofday, fatal\n");
	  exit(-1);
	}
	clock2=time(&clock2);
	//	if(clock1!=clock1_old||lRawTime!=lRawTime_old ||
	//   tv.tv_sec!=tv_sec_old||clock2!=clock2_old) {
	  printf(" clock1 %10d raw %10d secs %10d usc %10d clock2 %10d\n",
		 clock1,lRawTime,tv.tv_sec,tv.tv_usec,clock2);
	  //  clock1_old=clock1;
	  //  lRawTime_old=lRawTime;
	  // tv_sec_old=tv.tv_sec;
	  //  clock2_old=clock2;
	  //	}
     }

}
