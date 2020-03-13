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
/* For mark III/IV ifadjust snap command */
/* reset video converters back to where they were when ifadjust started. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int reset_vc(
char *vc_parms_save[14][10],
int vcnum_l[14],
int vcnum_u[14]
)
{
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  int ip[5];
  int iclass;

  for (i=0;i<14;i++) {
    int j;
    for(j=0;j<14;j++) {
      if(vcnum_l[j]==i||vcnum_u[j]==i) {
	goto get;
      }
    }
    continue;
  get:
    iclass=0;
    nrec=0;
    buff[0]=0;
    memcpy(buff+1,&vc_parms_save[i],10);
    cls_snd(&iclass,buff,12,0,0);nrec++;
    
    ip[0]=iclass;
    ip[1]=nrec;
    
    skd_run("matcn",'w',ip);
    skd_par(ip);
      
    if(ip[2]<0) return ierr;
    cls_clr(ip[0]);
  }

  return ierr;
}
