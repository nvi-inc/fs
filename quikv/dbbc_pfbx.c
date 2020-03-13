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
/* dbbc_pfbx snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc_pfbx(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
  int ilast, ierr,count,i,iend,j,found;
  char *ptr;
  int out_recs, out_class;
  char outbuf[BUFSIZE];
  
  int dbbc_pfbx_dec();               /* parsing utilities */
  char *arg_next();
  
  void dbbc_pfbx_dis();
  void skd_run(), skd_par();      /* program scheduling utilities */
  
  if(DBBC!=shm_addr->equip.rack ||
     (DBBC_PFB != shm_addr->equip.rack_type &&
      DBBC_PFB_FILA10G != shm_addr->equip.rack_type)) {
    ierr=-501;
    goto error;
  }
  
  if (command->equal != '=') {            /* read module */
    out_recs=0;
    out_class=0;
    
    sprintf(outbuf,"power=%02d",itask);    /* '01'-'04' */
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;
    goto dbbcn;
  } 

  /* anything else: setting or =? */
  ierr=-301;
  goto error;
  
  
dbbcn:
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("dbbcn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) {
    if(command->equal == '=' && -201 == ip[2]) {
      logitn(NULL,ip[2],ip+3,ip[4]);
      ip[2]=-302;
      memcpy(ip+3,"dp",2);
    }
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    return;
  }
  
  dbbc_pfbx_dis(command,itask,ip);
  return;
  
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"dp",2);
  return;
}
