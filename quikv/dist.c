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
/* vlba ifd snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void dist(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, i, count;
      char *ptr;
      struct req_rec request;          /* mcbcn request record */
      struct req_buf buffer;           /* mcbcn request buffer */
      struct dist_cmd lcl;            /* local instance of dist command strcu */

      int dist_dec();                 /* parsing utilities */
      char *arg_next();

      void dist01mc(), dist02mc();    /* dist utilities */
      void dist_dis();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_req(&buffer);

      ind=itask-1;                    /* index for this module */

      if(ind == 0)    /* device mnemonic */
        memcpy(request.device,DEV_VIA,2);
      else
        memcpy(request.device,DEV_VIC,2);
  
      if (command->equal != '=') {            /* read module */
         request.type=1;
         request.addr=0x01; add_req(&buffer,&request);
         request.addr=0x02; add_req(&buffer,&request);
         request.addr=0x04; add_req(&buffer,&request);
         request.addr=0x06; add_req(&buffer,&request);
         request.addr=0x07; add_req(&buffer,&request);
         goto mcbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            dist_dis(command,itask,ip);
            return;
         } else if(0==strcmp(command->argv[0],ADDR_ST)) {
            request.type=2; add_req(&buffer,&request);
            goto mcbcn;
         } else if(0==strcmp(command->argv[0],TEST)) {
            request.type=4; add_req(&buffer,&request);
            goto mcbcn;
         } 

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dist[ind],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dist_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.dist[ind];
      shm_addr->check.dist[ind]=0;
      memcpy(&shm_addr->dist[ind],&lcl,sizeof(lcl));
      
/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0x01;
      dist01mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x02;
      dist02mc(&request.data,&lcl); add_req(&buffer,&request);

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.dist[ind]=ichold;
      }

      if(ip[2]<0) return;
      dist_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vi",2);
      return;
}
