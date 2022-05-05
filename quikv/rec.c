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
/* vlba eec snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <limits.h>

#include "../include/params.h"
#include "../include/macro.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static float spd[ ]={0,3.375,7.875,16.875,33.75,67.5,135.,270.};
void rec(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, indx, i, count, ichold;
      int kenable, klowtape, kmove, kload;
      char *ptr;
      struct req_rec request;       /* mcbcn request record */
      struct req_buf buffer;        /* mcbcn request buffer */
      struct venable_cmd lcl;        /* general recording structure */

      int rec_dec();                 /* parsing utilities */
      char *arg_next();
      float fvacuum;

      int verr, lerr, vacuum(), volt;
      
      void rec_dis();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */
      void venable81mc();

      ichold = -99;
      kenable = FALSE;
      kmove = FALSE;
      kload = FALSE;
      klowtape = FALSE;

      ini_req(&buffer);

      indx=itask-1;                    /* index for this module */

      if(indx == 0) 
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);

      if (command->equal != '=') {            /* read module */
        request.type=1;
        request.addr=0x30; add_req(&buffer,&request);
        if (!((shm_addr->equip.drive[indx] == VLBA &&
	    shm_addr->equip.drive_type[indx] == VLBA2)||
	    (shm_addr->equip.drive[indx] == VLBA4 &&
	    shm_addr->equip.drive_type[indx] == VLBA42))) {
          request.addr=0x31; add_req(&buffer,&request);
          request.addr=0x32; add_req(&buffer,&request);
        }
        request.addr=0x71; add_req(&buffer,&request);
        goto mcbcn;
      }
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            rec_dis(command,ip,indx);
            return;
         } else if(0==strcmp(command->argv[0],ADDR_ST)) {
            request.type=2; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],TEST)) {
            request.type=4; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],REBOOT)) {
	    if((shm_addr->equip.drive[indx] == VLBA &&
	       shm_addr->equip.drive_type[indx] == VLBA2)||
	       (shm_addr->equip.drive[indx] == VLBA4 &&
		shm_addr->equip.drive_type[indx] == VLBA42)){
	      ierr= -205;
	      goto error;
	    }
            request.type=0;
            request.addr=0xe5;
            request.data=0xae51; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],"load")) {
            request.type=0;
	    if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4 ||
	       shm_addr->equip.rack == K4MK4 ) {
	      setMK4FMrec(0,ip);
	      if(ip[2]<0)
		return;
	    }

	    if (!((shm_addr->equip.drive[indx] == VLBA &&
		shm_addr->equip.drive_type[indx] == VLBA2)||
		  (shm_addr->equip.drive[indx] == VLBA4 &&
		shm_addr->equip.drive_type[indx] == VLBA42))) {
	      if(shm_addr->vacsw[indx] == 1 && shm_addr->thin[indx]!= 0 &&
		 shm_addr->thin[indx]!=1) {
		ierr=-206;
		goto error;
	      }
	      request.addr=0xb9;                 /* capstan size */
	      request.data= bits16on(16) & (shm_addr->capstan[indx]); 
	      add_req(&buffer,&request);

              request.addr=0xbd;                 /* tape thickness */
	      if(shm_addr->vacsw[indx] == 1 )
		if(shm_addr->thin[indx])
		  request.data= bits16on(16) & shm_addr->itpthick[indx];
		else
		  request.data= bits16on(16) & shm_addr->itpthick2[indx];
	      else 
		request.data= bits16on(16) & shm_addr->itpthick[indx];

              add_req(&buffer,&request);

              request.addr=0xd0;               /* vacuum motor voltage (mV) */
	      if(shm_addr->vacsw[0] == 1 )
		if(shm_addr->thin[indx])
		  fvacuum=
		    (shm_addr->motorv[indx]*shm_addr->inscsl[indx]) +
		    shm_addr->inscint[indx];
		else
		  fvacuum=
		    (shm_addr->motorv2[indx]*shm_addr->inscsl[indx]) +
		    shm_addr->inscint[indx];
	      else
		  fvacuum=
		    (shm_addr->motorv[indx]*shm_addr->inscsl[indx]) +
		    shm_addr->inscint[indx];

              request.data = bits16on(14) & (int)(fvacuum);
              add_req(&buffer,&request);

              request.addr=0xd3;                 /* head 1 write voltage */
/* the write voltage (millivolts) to send to record is divided by 2 */

	      if(shm_addr->vacsw[indx] == 1 )
		if(shm_addr->thin[indx])
		  volt = (int)((shm_addr->wrvolt[indx]/2)*1000);
		else
		  volt = (int)((shm_addr->wrvolt2[indx]/2)*1000);
	      else
		  volt = (int)((shm_addr->wrvolt[indx]/2)*1000);

              request.data= bits16on(14) & volt;
              add_req(&buffer,&request);

	      if(shm_addr->equip.drive[indx] == VLBA4 ||
		 (shm_addr->equip.drive[indx] == VLBA &&
		  shm_addr->equip.drive_type[indx] == VLBAB)) {
		request.addr=0xd2;                 /* head 2 write voltage */
/* the write voltage (millivolts) to send to record is divided by 2*/
		if(shm_addr->vacsw[indx] == 1 )
		  if(shm_addr->thin[indx])
		    volt = (int)((shm_addr->wrvolt4[indx]/2)*1000);
		  else
		    volt = (int)((shm_addr->wrvolt42[indx]/2)*1000);
		else
		  volt = (int)((shm_addr->wrvolt4[indx]/2)*1000);

		request.data= bits16on(14) & volt;
		add_req(&buffer,&request);
	      }

	      shm_addr->thin[indx]=-1;
	    } else {

             request.addr=0xd3;                 /* head write voltage */
/* the write current (milliampers) in unitx of 0.2128 mA/count */
             request.data= bits16on(14) & (int)((shm_addr->wrvolt[indx]/0.2128)+0.5);
             add_req(&buffer,&request);
	   }

            request.addr=0xb3; /* load tape into vacuum */
            request.data=0x01; add_req(&buffer,&request);
            kload=TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"unload")) {
           verr=0;
           lerr=0;
           verr = vacuum(&lerr,indx);
           if (verr<0) {
             /* vacuum not ready or other error */
             ierr = verr;
             goto error;
           } 
           else if (lerr!=0) { 
             /* error with trying to read recorder */
             ierr = lerr;
             goto error;
           } 

	   if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4 ||
	      shm_addr->equip.rack == K4MK4 ) {
	     setMK4FMrec(0,ip);
	     if(ip[2]<0)
	       return;
	   }

	    request.type=0;
            memcpy(&lcl,&shm_addr->venable[indx],sizeof(lcl));
            lcl.general=0;                  /* turn off record */
            shm_addr->venable[indx].general=0;
            venable81mc(&request.data,&lcl);
            request.addr=0x81; add_req(&buffer,&request);

            request.addr=0xb4;
            request.data=0x01; add_req(&buffer,&request);
            shm_addr->idirtp[indx]=0;
            shm_addr->lowtp[indx]=1;

            kenable = TRUE;
            kmove = TRUE;
            klowtape = TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"bot")) {
           verr=0;
           lerr=0;
           verr = vacuum(&lerr,indx);
           if (verr<0) {
             /* vacuum not ready or other error */
             ierr = verr;
             goto error;
           } 
           else if (lerr!=0) { 
             /* error with trying to read recorder */
             ierr = lerr;
             goto error;
           } 

	   if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4  ||
	      shm_addr->equip.rack == K4MK4) {
	     setMK4FMrec(0,ip);
	     if(ip[2]<0)
	       return;
	   }

            request.type=0;
            memcpy(&lcl,&shm_addr->venable[indx],sizeof(lcl));
            lcl.general=0;                  /* turn off record */
            shm_addr->venable[indx].general=0;
            venable81mc(&request.data,&lcl);
            request.addr=0x81;
            add_req(&buffer,&request);

            request.addr=0xb5;           /* schedule tape speed */
            if (shm_addr->imaxtpsd[indx] == -2) {
              request.data=bits16on(16) & (int)(360*100.0);
            } else if (shm_addr->imaxtpsd[indx] == -1) {
              request.data=bits16on(16) & (int)(330*100.0);
            } else {
              request.data=
		bits16on(16) & (int)(spd[shm_addr->imaxtpsd[indx]]*100.0);
            }
	   shm_addr->ispeed[indx]=-3;
	   shm_addr->cips[indx]=request.data;
            add_req(&buffer,&request);

            request.addr=0xb6;           /* set low tape sensor */
            shm_addr->lowtp[indx]=1;
            request.data= bits16on(1) & 1; 
            add_req(&buffer,&request);

            request.addr=0xb1; request.data=0x00; 
            shm_addr->idirtp[indx]=0;
            add_req(&buffer,&request);
            kenable = TRUE;
            kmove = TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"eot")) {
           verr=0;
           lerr=0;
           verr = vacuum(&lerr,indx);
           if (verr<0) {
             /* vacuum not ready or other error */
             ierr = verr;
             goto error;
           } 
           else if (lerr!=0) { 
             /* error with trying to read recorder */
             ierr = lerr;
             goto error;
           } 
	   if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4  ||
	      shm_addr->equip.rack == K4MK4) {
	     setMK4FMrec(0,ip);
	     if(ip[2]<0)
	       return;
  	   }

            request.type=0;
            memcpy(&lcl,&shm_addr->venable[indx],sizeof(lcl));
            lcl.general=0;                  /* turn off record */
            shm_addr->venable[indx].general=0;
            venable81mc(&request.data,&lcl);
            request.addr=0x81;
            add_req(&buffer,&request);

            request.addr=0xb5;           /* schedule tape speed */
            if (shm_addr->imaxtpsd[indx] == -2) {
              request.data=bits16on(16) & (int)(360*100.0);
            } else if (shm_addr->imaxtpsd[indx] == -1) {
              request.data=bits16on(16) & (int)(330*100.0);
            } else {
              request.data=
		bits16on(16) & (int)(spd[shm_addr->imaxtpsd[indx]]*100.0);
            }
	   shm_addr->ispeed[indx]=-3;
	   shm_addr->cips[indx]=request.data;
            add_req(&buffer,&request);

            request.addr=0xb6;           /* set low tape sensor */
            request.data= bits16on(1) & 1; 
            shm_addr->lowtp[indx]=1;
            add_req(&buffer,&request);

            request.addr=0xb1; request.data=0x01; 
            shm_addr->idirtp[indx]=1;
            add_req(&buffer,&request);
            kenable = TRUE;
            kmove = TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"release")) {
            request.type=0;
	    if(!((shm_addr->equip.drive[indx] == VLBA &&
	       shm_addr->equip.drive_type[indx] == VLBA2)||
		 (shm_addr->equip.drive[indx] == VLBA4 &&
	       shm_addr->equip.drive_type[indx] == VLBA42))) {
              request.addr=0xd0;
              request.data=0x00; add_req(&buffer,&request);
	    }
            request.addr=0xba;
            request.data=0x01; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],"zero")) {
	    if((shm_addr->equip.drive[indx] == VLBA &&
	       shm_addr->equip.drive_type[indx] == VLBA2)||
	       (shm_addr->equip.drive[indx] == VLBA4 &&
		shm_addr->equip.drive_type[indx] == VLBA42)){
	      ierr= -203;
	      goto error;
	    }
            request.type=0;
            request.addr=0xb8;
            request.data=0x00; add_req(&buffer,&request);
            goto mcbcn;

         } else { 
             ierr = rec_dec(command->argv[0],&request,&buffer,ip,indx);
             kmove = TRUE;
             if (ierr!=0) {
	       ip[0]=ip[1]=0;
	       ip[2]=ierr;
	       return;
	     }
	     if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4 ||
		shm_addr->equip.rack == K4MK4 ) {
	       setMK4FMrec(0,ip);
	       if(ip[2]<0)
		 return;
	     }

         }

parse:

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.rec[indx];
      shm_addr->check.rec[indx]=0;

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
         if (kmove) {
            shm_addr->check.vkmove[indx] = FALSE;
            rte_rawt(shm_addr->check.rc_mv_tm+0);
         }
         if (kenable)
            shm_addr->check.vkenable[indx] = FALSE;
         if (klowtape)
            shm_addr->check.vklowtape[indx] = FALSE;
         if (kload){
            shm_addr->check.vkload[indx] = TRUE;
            rte_rawt(&shm_addr->check.rc_ld_tm+indx);
         }
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.rec[indx]=ichold;
      }

display:
      if(ip[2]<0) return;
      rec_dis(command,ip,indx);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rc",2);
      return;
}
