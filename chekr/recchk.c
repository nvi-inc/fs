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
/* chekr rec routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void recchk_(icherr,ierr,indxtp,stat)
int icherr[];
int *ierr,*indxtp,*stat;
{
  int ip[5];                   /* ipc parameters */
  struct req_rec request;       /* mcbcn request record */
  struct req_buf buffer;        /* mcbcn request buffer */
  struct vst_cmd lcl;
  struct venable_cmd lcv;        /* general recording structure */

  char *arg_next();

  void rec_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  int indx;

  if(*indxtp == 1) {
    indx=0;
  } else if(*indxtp == 2) {
    indx=1;
  } else {
    ip[2]=-505;
    memcpy("q<",ip+4,2);
    return;
  }

  ini_req(&buffer);

  if(indx == 0) 
    memcpy(request.device,"r1",2);
  else 
    memcpy(request.device,"r2",2);

  request.type=1;
  request.addr=0x73; add_req(&buffer,&request);
  if(*stat==0) {
    request.addr=0x81; add_req(&buffer,&request);
    request.addr=0xb1; add_req(&buffer,&request);
    request.addr=0xb5; add_req(&buffer,&request);
    request.addr=0xb6; add_req(&buffer,&request);
  }
  request.addr=0x30; add_req(&buffer,&request);
 

  end_req(ip,&buffer);
  nsem_take("fsctl",0);

  skd_run("mcbcn",'w',ip);

  nsem_put("fsctl");
  skd_par(ip);

  if (ip[2]<0) {
    cls_clr(ip[0]);
    logita(NULL,ip[2],ip+3,ip+4);
    *ierr=-201;
    return;
  }

  rec_brk(icherr,ierr,ip,indx,*stat);

  return;

}
