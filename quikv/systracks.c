/* vlba systracks snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void systracks(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, indx, ichold, i, count;
      char *ptr;
      struct req_rec request;       /* mcbcn request record */
      struct req_buf buffer;        /* mcbcn request buffer */
      struct systracks_cmd lcl; /* local instance of systracks command struc */

      int systracks_dec();                 /* parsing utilities */
      char *arg_next();

      void systracks82mc(), systracks83mc();    /* systrack utilities */
      void systracks84mc(), systracks85mc();
      void systracks_dis();

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
         request.addr=0x82; add_req(&buffer,&request);
         request.addr=0x83; add_req(&buffer,&request);

         request.addr=0x84; add_req(&buffer,&request);
         request.addr=0x85; add_req(&buffer,&request);
         goto mcbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            systracks_dis(command,itask,ip,indx);
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
      memcpy(&lcl,&shm_addr->systracks[indx],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=systracks_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.rec[0];
      shm_addr->check.rec[0]=0;
      memcpy(&shm_addr->systracks[0],&lcl,sizeof(lcl));
      
/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0x82;
      systracks82mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x83;
      systracks83mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x84;
      systracks84mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x85;
      systracks85mc(&request.data,&lcl); add_req(&buffer,&request);

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
        shm_addr->check.systracks[indx] = TRUE;
        if (ichold >= 0)
          ichold=ichold % 1000 + 1;
        shm_addr->check.rec[0]=ichold;
      }

      if(ip[2]<0) return;
      systracks_dis(command,itask,ip,indx);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vx",2);
      return;
}
