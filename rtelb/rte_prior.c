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
#include <errno.h>
#include <sys/time.h>
#include <sys/resource.h>

int rte_prior(ivalue)
int ivalue;
{
     int iret;

     errno=0;
     iret=getpriority(PRIO_PROCESS, 0);
     if(errno != 0) {
       perror("rte_prior: getting priority");
       iret= 0;
     }
     if( -1 == setpriority(PRIO_PROCESS, 0, ivalue)) {
       /*
       perror("rte_prior: setting priority");
       */
     }
  
     return iret;
}
