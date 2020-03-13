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

int antcn(ip1,ierr)
     int ip1;
     int *ierr;
{
  int ip[5] = {0,0,0,0,0};
  int i;

  ip[0]=ip1;

  for(i=0;i<2;i++) {
    if(brk_chk("onoff")!=0) {
      *ierr=-1;
      return -1;
    }
    skd_run("antcn",'w',ip);
    if(ip[2]>=0)
      return 0;
    logita(NULL,ip[2],ip+3,ip+4);
  }

  *ierr=-30;
  return -1;
}
