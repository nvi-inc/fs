/* vlba st snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vst(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr, indx;
      char *ptr;
      struct req_rec request;       /* mcbcn request record */
      struct req_buf buffer;        /* mcbcn request buffer */
      struct vst_cmd lcl;
      struct venable_cmd lcv;        /* general recording structure */

      int vacuum(), lerr;
      int vst_dec();                 /* parsing utilities */
      char *arg_next();

      void vst_dis(), vstb1mc(), vstb5mc();
      void venable81mc();
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
         request.addr=0xb5; add_req(&buffer,&request);
         request.addr=0xb1; add_req(&buffer,&request);
         goto mcbcn;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          vst_dis(command,ip,indx);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=vst_dec(&lcl,&count, ptr,indx);
        if(ierr !=0 ) goto error;
      }

/*  check for vacuum */

      end_req(ip,&buffer); 
      if(lcl.speed!=-3 && lcl.cips !=0) {
	verr=0;
	lerr=0;
	verr = vacuum(&lerr,indx);
	if (verr<0) {
	  /* vacuum not ready (-1) or other error (-2) */
	  ierr = verr;
	  goto error;
	} else if (lerr!=0) { 
	  /* error trying to read recorder */
	  ierr = lerr;
	  goto error;
	}
      }

      ini_req(&buffer);

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.rec[indx];
      shm_addr->check.rec[indx]=0;

      shm_addr->ispeed[indx]=lcl.speed;
      shm_addr->cips[indx]=lcl.cips;

      memcpy(&lcv,&shm_addr->venable[indx],sizeof(lcv));
      lcv.general=lcl.rec;                  /* turn record off or on */
      shm_addr->venable[indx].general=lcv.general;

/* if MK4 FM control record */

      if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4 ||
	 shm_addr->equip.rack == K4MK4 ) {
	setMK4FMrec(lcl.rec,ip);
	if(ip[2]<0)
	  return;
      }

/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0xb5;
      vstb5mc(&request.data,&lcl); add_req(&buffer,&request);

      venable80mc(&request.data,&lcv);
      request.addr=0x80;
      add_req(&buffer,&request);

      venable81mc(&request.data,&lcv);
      request.addr=0x81;
      add_req(&buffer,&request);

      request.addr=0xb1;
      vstb1mc(&request.data,&lcl); add_req(&buffer,&request);
      shm_addr->idirtp[indx]=lcl.dir;

      if(lcl.cips <500 &&
	 ((shm_addr->equip.drive[indx] == VLBA &&
	  shm_addr->equip.drive_type[indx] == VLBA2)||
	  (shm_addr->equip.drive[indx] == VLBA4 &&
	   shm_addr->equip.drive_type[indx] == VLBA42))) {
	request.addr=0xb0;
	request.data=0x01;
	add_req(&buffer,&request);
      }

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
         shm_addr->check.vkmove[indx] = TRUE;
         rte_rawt(shm_addr->check.rc_mv_tm+indx);
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.rec[indx]=ichold;
      }

      if(ip[2]<0) return;
      vst_dis(command,ip,indx);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vs",2);
      return;
}
