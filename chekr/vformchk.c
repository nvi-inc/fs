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
/* chekr formatter routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vformchk_(icherr,ierr)
int icherr[5];
int *ierr;
{
  int ip[5];                           /* ipc parameters */
  int i, j;
  unsigned int iptr;
  struct req_rec request;        /* mcbcn request record */
  struct req_buf buffer;         /* mcbcn request buffer */

  void vform_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

  request.type=0;                      /* set indirect track address */
  request.data=0;
  request.addr=0xD0; add_req(&buffer,&request);
  request.addr=0xD1; add_req(&buffer,&request);

  request.type=1; request.addr=0xD2;   /* get 32 track assignements */
  for (i=0;i<32;i++)
     add_req(&buffer,&request);

  request.addr=0x8D; add_req(&buffer,&request); /* low track enables */
  request.addr=0x8E; add_req(&buffer,&request); /* high track enables */
  request.addr=0x8F; add_req(&buffer,&request); /* system track enables*/
  request.addr=0x90; add_req(&buffer,&request);
  request.addr=0x91; add_req(&buffer,&request);
  request.addr=0x92; add_req(&buffer,&request);
  request.addr=0x93; add_req(&buffer,&request);
  request.addr=0x99; add_req(&buffer,&request);
  request.addr=0x9A; add_req(&buffer,&request);
  request.addr=0xAD; add_req(&buffer,&request);

  end_req(ip,&buffer);
  nsem_take("fsctl",0);
  skd_run("mcbcn",'w',ip);
  nsem_put("fsctl");
  skd_par(ip);

  if(ip[2]<0) {
    logita(NULL,ip[2],ip+3,ip+4);
    *ierr=-201;
    return;
  }

  vform_brk(ip,icherr,ierr);

  return;

}
