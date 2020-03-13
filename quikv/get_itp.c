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
/* mark III/IV ifadjust snap command */
/* get total power setting function. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int get_itp(
int *vcnum, 
int itpz[14],
int iuse[]
) {
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  int nchar,idum, *vcnum_tmp;
  char lvcn[] = {"v1v2v3v4v5v6v7v8v9vavbvcvdve"};
  int ip[5];
  int iclass;

  iclass=0;
  nrec = 0;
  buff[0]=-2;

  vcnum_tmp=vcnum;
  for (i=0;*vcnum!=-1 && i<14;i++,vcnum++)
    if(iuse[*vcnum]) {
      memcpy(buff+1,lvcn+(*vcnum*2),2);
      cls_snd(&iclass,buff,4,0,0); nrec++;
    }

  ip[0]=iclass;
  ip[1]=nrec;
  
  skd_run("matcn",'w',ip);
  skd_par(ip);

  if(ip[2]<0) return ierr;
    iclass=ip[0];

  if(nrec != ip[1]) {
    ierr=-503;
    cls_clr(ip[0]);
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"if",2);
    return ierr;
  }

  vcnum=vcnum_tmp;
  for (i=0;*vcnum!=-1 && i<14;i++,vcnum++)
    if(iuse[*vcnum]) {
      nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
      ((char *) buff)[nchar]=0;
      if(1!=sscanf(((char *)buff)+6,"%4x",&itpz[i])) {
	ierr=-504;
	ip[4]=i;
	ip[0]=0;
	ip[1]=0;
	ip[2]=ierr;
	memcpy(ip+3,"if",2);
	return ierr;
      }
    }

  return ierr;
}

