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
#include <string.h>
#include "../include/params.h"

static char *lvcn[]= { "v1","v2","v3","v4","v5","v6","v7","v8","v9","va", 
	       "vb","vc","vd","ve","vf" };

int tpi_mark(ip,itpis,ierr)
int ip[5];                                     /* ipc array */
int itpis[MAX_DET]; /* detector selection array */
int *ierr;
{
  int iclass, nrec, i;
  short int buf2[80];

      iclass=0;
      nrec=0;
      for(i=0;i<17;i++) {
	if(itpis[i]!=0 &&
	   (i!=15||(i==15&&itpis[14]==0))) {
	  if(i<14) {
	    buf2[0]=-22;
	    memcpy(buf2+1,lvcn[i],2);
	  } else if(i==14 || i==15) {
	    buf2[0]=-21;
	    memcpy(buf2+1,"if",2);
	  } else {
	    buf2[0]=-22;
	    memcpy(buf2+1,"i3",2);
	  }
	  cls_snd(&iclass,buf2,4,0,0); nrec++;
	}
      }
      if(matcn(ip,iclass,nrec,ierr))
	return -1;

      return 0;
}

