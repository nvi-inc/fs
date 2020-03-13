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
/* vlba recorder vacuum check */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char deviceA[]={"r1"};           /* device menemonics */
static char deviceB[]={"r2"};           /* device menemonics */

int vacuum(ierr,indx)
int *ierr, indx;
{
  int lierr;
  int ip[5];
  struct req_rec request;       /* mcbcn request record */
  struct req_buf buffer;        /* mcbcn request buffer */
  struct res_buf rbuffer;
  struct res_rec response;
  struct tape_mon lcl;

  void get_res(), opn_res();
  void mc73tape();     /* tape utility */
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  if ((shm_addr->equip.drive[indx] == VLBA &&
       shm_addr->equip.drive_type[indx] == VLBA2)||
      (shm_addr->equip.drive[indx] == VLBA4 &&
       shm_addr->equip.drive_type[indx] == VLBA42)) {
    /* ignore for VLBA2 and VLBA42 */
    lierr = 0;
    shm_addr->IRDYTP[indx] = 0;
    return lierr;
  }


/* tape ready does not seem to be reliable in RECON 4 */

  ini_req(&buffer);

  if(indx==0) 
    memcpy(request.device,deviceA,2);    /* device mnemonic */
  else
    memcpy(request.device,deviceB,2);    /* device mnemonic */

  request.type=1;
  request.addr=0x73; add_req(&buffer,&request);

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if(ip[2]<0) return;

  opn_res(&rbuffer,ip);
  get_res(&response, &rbuffer); mc73tape(&lcl, response.data);
  if (response.state == -1) {
    clr_res(&rbuffer);
    *ierr=-401;
    return;
  }
  clr_res(&rbuffer);

  if ((lcl.stat & 0x40) == 0) { 
     /* vacuum not ready */
    lierr = -1;
    shm_addr->IRDYTP[indx] = 1;
  }
#if 0
  else if ((lcl.stat & 0x01)==1) {
    /* error present */
    lierr = -2;
    shm_addr->IRDYTP[indx] = 1;
  }
#endif
  else {                             /* vacuum is ready */
    lierr = 0;
    shm_addr->IRDYTP[indx] = 0;
  }

  return lierr;
}
