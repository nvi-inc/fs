/* vlba repro snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vrepro(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, i, count;
      char *ptr;
      struct req_rec request;       /* mcbcn request record */
      struct req_buf buffer;        /* mcbcn request buffer */
      struct vrepro_cmd lcl;        /* local instance of vrepro command struc */

      int vepro_dec();                 /* parsing utilities */
      char *arg_next();

      void vrepro01mc(), vrepro02mc();    /* vrepro utilities */
      void vrepro_dis();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_req(&buffer);

      ind=itask-1;                    /* index for this module */

      memcpy(request.device,DEV_VRC,2);    /* device mnemonic */

      if (command->equal != '=') {            /* read module */
         request.type=1;
         request.addr=0x90; add_req(&buffer,&request);
         request.addr=0x91; add_req(&buffer,&request);

         request.addr=0x94; add_req(&buffer,&request);
         request.addr=0x95; add_req(&buffer,&request);

         request.addr=0x98; add_req(&buffer,&request);
         request.addr=0x99; add_req(&buffer,&request);
         goto mcbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            vrepro_dis(command,itask,ip);
            return;
         } else if(0==strcmp(command->argv[0],ADDR)) {
            ierr=-301;
            goto error;
         } else if(0==strcmp(command->argv[0],TEST)) {
            ierr=-301;
            goto error;
         } 

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->vrepro,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=vrepro_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.vrepro;
      shm_addr->check.vrepro=0;
      memcpy(&shm_addr->vrepro,&lcl,sizeof(lcl));
      
/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0x90;
      vrepro90mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x91;
      vrepro91mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x94;
      vrepro94mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x95;
      vrepro95mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x98;
      vrepro98mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x99;
      vrepro99mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0xa8;
      vreproa8mc(&request.data,&lcl); add_req(&buffer,&request);

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) shm_addr->check.vrepro=ichold;
      if (ichold >= 0) shm_addr->check.vrepro=ichold % 1000 + 1;

      if(ip[2]<0) return;
      vrepro_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vr",2);
      return;
}
