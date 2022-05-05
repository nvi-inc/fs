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

int matcn(ip,iclass,nrec,ierr)
     int ip[5];
     int iclass, nrec, *ierr;
{
  if(brk_chk("onoff")!=0) {
    *ierr=-1;
    return -1;
  }

  ip[0]=iclass;
  ip[1]=nrec;
  skd_run("matcn",'w',ip);
  skd_par(ip);
  if (ip[2]>=0)
    return 0;
  if(ip[1]!=0) {
    cls_clr(ip[0]);
    ip[0]=ip[1]=0;
  }
  logita(NULL,ip[2],ip+3,ip+4);

  *ierr=-17;
  return -1;
}
