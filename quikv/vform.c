/* vlba formatter snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vform(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int  aux_track, j, version;
      unsigned long iptr;
      unsigned itracks[32];
      char *ptr;
      struct req_rec request;        /* mcbcn request record */
      struct req_buf buffer;         /* mcbcn request buffer */
      struct vform_cmd lcl;          /* local instance of vform command */

      int vform_dec();                 /* parsing utilities */
      char *arg_next();

      void vform_dis(), vform_ver();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ierr=0;
      vform_ver(&version,ierr,ip);
      shm_addr->form_version = version;
   
      ini_req(&buffer);

      memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

      if (command->equal != '=') {            /* read module */

         request.type=0;                      /* set indirect track address */
         request.data=0;
         request.addr=0xD0; add_req(&buffer,&request);
         request.addr=0xD1; add_req(&buffer,&request);

         request.type=1; request.addr=0xD2;   /* get 32 track assignements */
         for (i=0;i<32;i++)
            add_req(&buffer,&request);

         request.addr=0x20; add_req(&buffer,&request); /* status */
         request.addr=0x21; add_req(&buffer,&request);
         request.addr=0x22; add_req(&buffer,&request);
         request.addr=0x23; add_req(&buffer,&request);
         request.addr=0x24; add_req(&buffer,&request);
         
         request.addr=0x60; add_req(&buffer,&request); /* version */
         request.addr=0x8D; add_req(&buffer,&request); /* low track enables */
         request.addr=0x8E; add_req(&buffer,&request); /* high track enables */
         request.addr=0x8F; add_req(&buffer,&request); /* system track enables*/
         request.addr=0x90; add_req(&buffer,&request);
         request.addr=0x91; add_req(&buffer,&request);
         request.addr=0x99; add_req(&buffer,&request);
         request.addr=0x9A; add_req(&buffer,&request);
         request.addr=0xAD; add_req(&buffer,&request);

         goto skip_aux;
         for (i=0;i<28;i++) {                   /* 28 tracks of aux data */
           if(i<14) aux_track=i+1; /* calculate formatter track number */
           else aux_track=i+3;

           iptr=aux_track*16;                   /* indirect address */

           request.type=0;                      /* set aux buffer address */
           request.data=0xFFFF & (iptr>>16);    /* msw */
           request.addr=0xD4; add_req(&buffer,&request);

           request.data=0xFFFF & iptr;          /* lsw */
           request.addr=0xD5; add_req(&buffer,&request);

           request.type=1;                      /* fetch aux data */
           request.addr=0xD6;
           for (j=0;j<4;j++) add_req(&buffer,&request);  /* 4 words per track */
         }
skip_aux:
         goto mcbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            vform_dis(command,itask,ip);
            return;
         } else if(0==strcmp(command->argv[0],ADDR)) {
            request.type=2; add_req(&buffer,&request);
            goto mcbcn;
         } else if(0==strcmp(command->argv[0],TEST)) {
            request.type=4; add_req(&buffer,&request);
            goto mcbcn;
         } else if(0==strcmp(command->argv[0],REBOOT)) {
            request.type=0;
            request.addr=0x81;
            request.data=0x8001; add_req(&buffer,&request);
            goto mcbcn;
         } 

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->vform,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=vform_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.vform;
      shm_addr->check.vform=0;
      memcpy(&shm_addr->vform,&lcl,sizeof(lcl));
      
      request.type=0;                /* clear MCB status register */
      request.addr=0xA1;
      request.data=0; add_req(&buffer,&request);
      
/* configure this stuff */

      request.type=0;
      request.addr=0x8D;
      vform8Dmc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x8E;
      vform8Emc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x8F;
      vform8Fmc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x90;
      vform90mc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x91;
      vform91mc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x99;
      vform99mc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x9A;
      vform9Amc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0x9D;
      vform9Dmc(&request.data, &lcl); add_req(&buffer,&request); 

      request.addr=0xA6; /* send rack ID */
      vformA6mc(&request.data, shm_addr->hwid); add_req(&buffer,&request); 

      request.addr=0xAD;
      vformADmc(&request.data, &lcl); add_req(&buffer,&request); 

      if(lcl.mode != 0) {
        request.type=0;                /* set indirect track address */
        request.data=0;                /* set indirect track address */
        request.addr=0xD0; add_req(&buffer,&request); 
        request.addr=0xD1; add_req(&buffer,&request); 

        vformD2mc(itracks, &lcl);

        request.addr=0xD2;                /* set 32 track assignements */
        for (i=0;i<32;i++) {
           request.data=itracks[ i];
           add_req(&buffer,&request);
        }
      }

      goto skip_aux2;
      if(lcl.mode != 0) {
        aux_config(&lcl,ip);          /* configure the aux data */
        if(ip[2]<0) return;
      }

skip_aux2:

      request.addr=0x82;                               /* configure */
      request.data=0x8001; add_req(&buffer, &request);

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) shm_addr->check.vform=ichold;
      if (ichold >= 0) shm_addr->check.vform=ichold % 1000 + 1;

      if(ip[2]<0) return;
      vform_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vf",2);
      return;
}
