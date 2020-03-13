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

int rte_prior(ivalue)
int ivalue;
{
     int iret,level;

     iret=rtpriority(RT_PRI_GET,level);
     if(iret==-1) {
       perror("getting old priority");
       exit(-1);
     }
     if(ivalue>-1 && ivalue <128)
       level=ivalue;
     else
       level=RT_PRI_OFF;

     if(rtpriority(RT_PRI_SET, level)==-1) {
       perror("setting priority");
       exit(-1);
     }

     return iret;
}
