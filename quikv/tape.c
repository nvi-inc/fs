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
/* vlba tape snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void tape(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, indx, ichold, i, count;
      char *ptr;
      struct req_rec request;       /* mcbcn request record */
      struct req_buf buffer;        /* mcbcn request buffer */
      struct tape_cmd lcl;

      int tape_dec();                 /* parsing utilities */
      char *arg_next();

      void tapeb6mc(), tapeb8mc();    /* tape utilities */
      void tape_dis();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_req(&buffer);

      indx=itask-1;                    /* index for this module */

      if(indx == 0) 
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);

      if (command->equal != '=') {            /* read module */
         request.type=1;
         request.addr=0xb6; add_req(&buffer,&request);
         request.addr=0x30; add_req(&buffer,&request);
         request.addr=0x33; add_req(&buffer,&request);
 	 if (!((shm_addr->equip.drive[indx] == VLBA &&
	       shm_addr->equip.drive_type[indx] == VLBA2)||
	       (shm_addr->equip.drive[indx] == VLBA4 &&
	       shm_addr->equip.drive_type[indx] == VLBA42))) {
	   request.addr=0x57; add_req(&buffer,&request);
	 }
         request.addr=0x72; add_req(&buffer,&request);
         request.addr=0x73; add_req(&buffer,&request);
         request.addr=0x74; add_req(&buffer,&request);
         goto mcbcn;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          tape_dis(command,itask,ip,indx);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=tape_dec(&lcl,&count, ptr,indx);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->lowtp[indx],&lcl,sizeof(lcl));
      ichold=shm_addr->check.rec[indx];
      shm_addr->check.rec[indx]=0;
      
/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0xb6;
      tapeb6mc(&request.data,&lcl); add_req(&buffer,&request);

      if (lcl.reset != -1) {
        request.type=0; 
        request.addr=0xb8;
        tapeb8mc(&request.data,&lcl); add_req(&buffer,&request);
      }

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
         shm_addr->check.vklowtape[indx] = TRUE;
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.rec[indx]=ichold;
      }

      if(ip[2]<0) return;
      tape_dis(command,itask,ip,indx);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vt",2);
      return;
}
