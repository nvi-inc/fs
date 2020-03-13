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
/* set upper or lower sideband */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int set_vc_sb(
int *vcnum, 
char which,
int iuse[],
char *vc_parms_save[14][10]
) {
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  int nchar,idum;
  char lvcn[] = {"v1v2v3v4v5v6v7v8v9vavbvcvdve"};
  int ip[5];
  int iclass;


  for (i=0;(*vcnum != -1) && i<14;i++) {
    if(iuse[*vcnum]) {
      iclass=0;
      nrec=0;
      buff[0]=0;
      /* memcpy(buff+1,&vc_parms_save[vcnum[i]],10);*/
      memcpy(buff+1,&vc_parms_save[*vcnum++],10);
      if(which=='l') memcpy(buff+2,"1",1);
      else memcpy(buff+2,"2",1);
      cls_snd(&iclass,buff,12,0,0);nrec++;
      
      ip[0]=iclass;
      ip[1]=nrec;
      
      skd_run("matcn",'w',ip);
      skd_par(ip);
      
      if(ip[2]<0) return ierr;
      cls_clr(ip[0]);
    }
  }
  return ierr;
}

