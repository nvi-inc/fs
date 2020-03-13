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
/* vlba dqa snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void dqa(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      struct req_rec request;          /* mcbcn request record */
      struct req_buf buffer;           /* mcbcn request buffer */
      struct dqa_cmd lcl;            /* local instance of dqa command strcu */

      int dqa_dec();                 /* parsing utilities */
      char *arg_next();

      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_req(&buffer);

      ind=itask-1;                    /* index for this module */

      memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

      if (command->equal != '=')             /* get data */
         if(shm_addr->dqa.dur <= 0) {
           ierr=-501;
           goto error;
         } else
           goto dqa;
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            dqa_dis(command,itask,ip);
            return;
         } else if(0==strcmp(command->argv[0],ADDR_ST)) {
            ierr=-301;
            goto error;
         } else if(0==strcmp(command->argv[0],TEST)) {
            ierr=-301;
            goto error;
         } 

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dqa,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dqa_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->dqa,&lcl,sizeof(lcl));
      ip[0]=ip[1]=ip[2]=0;
      return;
      
/* format buffers for mcbcn */
dqa:
      if(shm_addr->vform.qa.drive!=0&&shm_addr->vform.qa.drive!=1) {
	ierr=-502;
	goto error;
      }

      request.type=0;                  /*start analysis */
      request.addr=0x88;
      request.data=0x8001;
      add_req(&buffer,&request);
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2]<0) return;
      cls_clr(ip[0]);

      rte_sleep((unsigned)(shm_addr->dqa.dur*100));   /* wait requested time */

      ini_req(&buffer);                        /* stop analysis */
      request.data=0x8000;
      add_req(&buffer,&request);
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2]<0) return;
      cls_clr(ip[0]);

      ini_req(&buffer);                                 /* retrieve results */
      request.type=1;
      request.addr=0x08; add_req(&buffer,&request);
      request.type=0;
      request.data=0;                                   /* set array index */
      request.addr=0xC8; add_req(&buffer,&request);
      request.addr=0xC9; add_req(&buffer,&request);

      request.type=1;                                   /* fetch array */
      request.addr=0xCA;
      for (i=0;i<36;i++)
         add_req(&buffer, &request);

      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) return;
      dqa_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vq",2);
      return;
}
