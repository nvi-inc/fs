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
#include "../include/params.h"

#define MAX_BUF 256

void tpget_mark(ip,itpis,tpi)
int ip[5];                                     /* ipc array */
int itpis[MAX_DET]; /* detector selection array */
float tpi[MAX_DET]; /* detector value array */
{
  int nrec, iclass, nr, i, idum, nchar, ierr;
  char buf3[MAX_BUF];

  nrec = ip[1];
  iclass = ip[0];
  nr=0;
  for(i=0;i<17;i++) {
    int ipwr;
    if (itpis[i]==0)
      continue;
    if(i!=15||itpis[14]==0) {
      if(nr>=nrec)
	continue;
      nchar=cls_rcv(iclass,&ierr,MAX_BUF,&idum,&idum,0,0);
      nchar=cls_rcv(iclass,buf3,MAX_BUF,&idum,&idum,0,0);
      nr=nr+2;
    }
    if(ierr>=0 && 1== sscanf(buf3+(i<=14?6:2),"%4x",&ipwr)) {
      if(ipwr>=65535)
	tpi[i+14]=1e9;
      else 
	tpi[i+14]=ipwr;
    } else if(ierr<0)
      tpi[i+14]=ierr;
    else
      tpi[i+14]=-9999;
  }
}
