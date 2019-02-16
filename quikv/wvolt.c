/* vlba wvolt snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void wvolt(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, indx, i, count;
      char *ptr;
      struct req_rec request;          /* mcbcn request record */
      struct req_buf buffer;           /* mcbcn request buffer */
      struct wvolt_cmd lcl;        /* local instance of wvolt command struct */

      int wvolt_dec();                 /* parsing utilities */
      char *arg_next();

      void wvolt_dis();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      indx=itask-1;                    /* index for this module */

      if((shm_addr->equip.drive[indx] == VLBA &&
	 shm_addr->equip.drive_type[indx] == VLBA2)||
	 (shm_addr->equip.drive[indx] == VLBA4 &&
	  shm_addr->equip.drive_type[indx] == VLBA42)){
	ierr=-401;
	goto error;
      }

      ini_req(&buffer);

      if(indx == 0) 
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);
  
      if (command->equal != '=') {            /* read module */
         request.type=1;
         request.addr=0xd3; add_req(&buffer,&request);
	 if(shm_addr->equip.drive[indx] == VLBA4||
	    (shm_addr->equip.drive[indx]==VLBA &&
	     shm_addr->equip.drive_type[indx]==VLBAB)) {
	   request.addr=0xd2; add_req(&buffer,&request);
	 }
         goto mcbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            wvolt_dis(command,itask,ip,indx);
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
      memcpy(&lcl,&shm_addr->wvolt[indx],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=wvolt_dec(&lcl,&count, ptr,indx);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->wvolt[indx],&lcl,sizeof(lcl));
      
/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0xd3;
      wvoltD3mc(&request.data,&lcl);
      add_req(&buffer,&request);

      if(shm_addr->equip.drive[indx] == VLBA4||
	 (shm_addr->equip.drive[indx]==VLBA &&
	  shm_addr->equip.drive_type[indx]==VLBAB)) {
	request.addr=0xd2;
	wvoltD2mc(&request.data,&lcl);
	add_req(&buffer,&request);
      }
      
mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) return;
      wvolt_dis(command,itask,ip,indx);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ro",2);
      return;
}
