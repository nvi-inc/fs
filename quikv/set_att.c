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
/* attenuation setting function. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int set_att(
int ifone,
int iftwo,
int ifthree,
int patched_ifs[],
int iat[],
char isave[],
char *isave3
)
{
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  int ip[5];
  int iclass;

  iclass=0;
  nrec=0;

  /* okay get the IF attenuation */

  if(patched_ifs[0]>0 || patched_ifs[1]>0) {
    buff[0]=0;
    memcpy(buff+1,"if",2);
    memcpy(buff+2,isave,4);
    sprintf(((char *)buff)+8,"%02x%02x",iftwo,ifone);
    cls_snd(&iclass,buff,12,0,0);nrec++;
  }
  /* okay get the IF3 attenuator setting */
  if(patched_ifs[2]>0){
    buff[0]=0;
    memcpy(buff+1,"i300000",7);
    iat[3]|=ifthree;
    sprintf(((char *)buff)+9,"%c%02x",*isave3,iat[3]);
    iat[3]&=0xc0;
    cls_snd(&iclass,buff,12,0,0);nrec++;
  } 
  if(nrec > 0) {
    ip[0]=iclass;
    ip[1]=nrec;
    
    skd_run("matcn",'w',ip);
    skd_par(ip);

    if(ip[2]<0) return ierr;
    cls_clr(ip[0]);

  }
  return ierr;
}
