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

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void rte_rawt();

int rte_secs()
{
     time_t clock1, clock2;
     int centisec;

     clock1=0;
     centisec=1;
     clock2=1;
     while(clock1!=clock2 && ((centisec%100) <2)) {
	clock1=time(&clock1);       /* bracket the centi-seconds */
        rte_rawt(&centisec);
	clock2=time(&clock2);
	rte_sleep((unsigned) 1);
	}
     return (clock2-(centisec/100));
}
