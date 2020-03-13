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
/* ifd chekr routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void distchk_(imod,icherr,ierr)
int *imod;
int *ierr;
int icherr[5];
{
  int ip[5];                           /* ipc parameters */
  int ind;
  struct req_rec request;          /* mcbcn request record */
  struct req_buf buffer;           /* mcbcn request buffer */

  void dist_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  ind=*imod-1;                    /* index for this module */

  if(ind == 0)    /* device mnemonic */
    memcpy(request.device,DEV_VIA,2);
  else
    memcpy(request.device,DEV_VIC,2);
  
  request.type=1;
  request.addr=0x01; add_req(&buffer,&request);
  request.addr=0x02; add_req(&buffer,&request);
  request.addr=0x06; add_req(&buffer,&request);
  request.addr=0x07; add_req(&buffer,&request);

  end_req(ip,&buffer);
  nsem_take("fsctl",0);
  skd_run("mcbcn",'w',ip);
  nsem_put("fsctl");
  skd_par(ip);

  if(ip[2]<0) {
    shm_addr->vifd_tpi[2*ind+0]=65536;
    shm_addr->vifd_tpi[2*ind+1]=65536;
    logita(NULL,ip[2],ip+3,ip+4);
    *ierr=-201;
    return;
  }

  dist_brk(imod,ip,icherr,ierr);

  return;

}
