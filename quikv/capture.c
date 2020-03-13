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
/* vlba capture snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void capture(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, i, count;
      char *ptr;
      struct req_rec request;          /* mcbcn request record */
      struct req_buf buffer;           /* mcbcn request buffer */

      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_req(&buffer);

      memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

      if (command->equal == '=')  {     /* no parameters */
           ierr=-301;
           goto error;
         } 

      request.type=0;                  /* start capture */
      request.addr=0x89;
      request.data=0x8001;
      add_req(&buffer,&request);
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2]<0) return;
      cls_clr(ip[0]);

      rte_sleep((unsigned)100);   /* wait the shortest time */

      ini_req(&buffer);                                 /* retrieve results */
      request.type=1;                                   /* set array index */
      request.addr=0x09; add_req(&buffer,&request);
      request.addr=0x48; add_req(&buffer,&request);
      request.addr=0x49; add_req(&buffer,&request);
      request.addr=0x4A; add_req(&buffer,&request);
      request.addr=0x4B; add_req(&buffer,&request);

      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) return;
      capture_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vc",2);
      return;
}
