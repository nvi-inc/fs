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
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count, ichold;
      int kenable, klowtape, kmove, kload;
      char *ptr;
      struct req_rec request;       /* mcbcn request record */
      struct req_buf buffer;        /* mcbcn request buffer */
      struct venable_cmd lcl;        /* general recording structure */

      int rec_dec();                 /* parsing utilities */
      char *arg_next();
      float fvacuum;

      int verr, lerr, vacuum();
      
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

      ind=itask-1;                    /* index for this module */

      memcpy(request.device,DEV_VRC,2);    /* device mnemonic */

      if (command->equal != '=') {            /* read module */
        request.type=1;
        request.addr=0x30; add_req(&buffer,&request);
        request.addr=0x31; add_req(&buffer,&request);
        request.addr=0x32; add_req(&buffer,&request);
        request.addr=0x71; add_req(&buffer,&request);
        goto mcbcn;
      }
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            rec_dis(command,ip);
            return;
         } else if(0==strcmp(command->argv[0],ADDR)) {
            request.type=2; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],TEST)) {
            request.type=4; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],REBOOT)) {
            request.type=0;
            request.addr=0xe5;
            request.data=0xae51; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],"load")) {
            request.type=0;
            request.addr=0xb9;                 /* capstan size */
            request.data= bits16on(16) & (shm_addr->capstan); 
            add_req(&buffer,&request);

            request.addr=0xbd;                 /* tape thickness */
            request.data= bits16on(16) & shm_addr->itpthick;
            add_req(&buffer,&request);

            fvacuum= 0.0;
            request.addr=0xd0;                 /* vacuum motor voltage (mV) */
            fvacuum=(shm_addr->motorv * shm_addr->inscsl) + shm_addr->inscint;
            request.data = bits16on(14) & (int)(fvacuum);
            add_req(&buffer,&request);

            request.addr=0xd3;                 /* head write voltage */
/* the write voltage (millivolts) to send to record is a factor of 2 */
            request.data= bits16on(14) & (int)((shm_addr->wrvolt/2)*1000);
            add_req(&buffer,&request);

            request.addr=0xb3; /* load tape into vacuum */
            request.data=0x01; add_req(&buffer,&request);
            kload=TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"unload")) {
           verr=0;
           lerr=0;
           verr = vacuum(&lerr);
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
            request.type=0;
            memcpy(&lcl,&shm_addr->venable,sizeof(lcl));
            lcl.general=0;                  /* turn off record */
            shm_addr->venable.general=0;
            venable81mc(&request.data,&lcl);
            request.addr=0x81; add_req(&buffer,&request);

            request.addr=0xb4;
            request.data=0x01; add_req(&buffer,&request);
            shm_addr->idirtp=-1;
            shm_addr->lowtp=1;

            kenable = TRUE;
            kmove = TRUE;
            klowtape = TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"bot")) {
           verr=0;
           lerr=0;
           verr = vacuum(&lerr);
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
            request.type=0;
            memcpy(&lcl,&shm_addr->venable,sizeof(lcl));
            lcl.general=0;                  /* turn off record */
            shm_addr->venable.general=0;
            venable81mc(&request.data,&lcl);
            request.addr=0x81;
            add_req(&buffer,&request);

            request.addr=0xb5;           /* schedule tape speed */
            if (shm_addr->iskdtpsd == -2) {
              request.data=bits16on(16) & (int)(360*100.0);
            } else if (shm_addr->iskdtpsd == -1) {
              request.data=bits16on(16) & (int)(330*100.0);
            } else {
              request.data=bits16on(16) & (int)(spd[shm_addr->iskdtpsd]*100.0);
            }
            shm_addr->ispeed=shm_addr->iskdtpsd;
            add_req(&buffer,&request);

            request.addr=0xb6;           /* set low tape sensor */
            shm_addr->lowtp=1;
            request.data= bits16on(1) & 1; 
            add_req(&buffer,&request);

            request.addr=0xb1; request.data=0x00; 
            shm_addr->idirtp=-1;
            add_req(&buffer,&request);
            kenable = TRUE;
            kmove = TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"eot")) {
           verr=0;
           lerr=0;
           verr = vacuum(&lerr);
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
            request.type=0;
            memcpy(&lcl,&shm_addr->venable,sizeof(lcl));
            lcl.general=0;                  /* turn off record */
            shm_addr->venable.general=0;
            venable81mc(&request.data,&lcl);
            request.addr=0x81;
            add_req(&buffer,&request);

            request.addr=0xb5;           /* schedule tape speed */
            if (shm_addr->iskdtpsd == -2) {
              request.data=bits16on(16) & (int)(360*100.0);
            } else if (shm_addr->iskdtpsd == -1) {
              request.data=bits16on(16) & (int)(330*100.0);
            } else {
              request.data=bits16on(16) & (int)(spd[shm_addr->iskdtpsd]*100.0);
            }
            shm_addr->ispeed=shm_addr->iskdtpsd;
            add_req(&buffer,&request);

            request.addr=0xb6;           /* set low tape sensor */
            request.data= bits16on(1) & 1; 
            shm_addr->lowtp=1;
            add_req(&buffer,&request);

            request.addr=0xb1; request.data=0x01; 
            shm_addr->idirtp=-1;
            add_req(&buffer,&request);
            kenable = TRUE;
            kmove = TRUE;
            goto parse;

         } else if(0==strcmp(command->argv[0],"release")) {
            request.type=0;
            request.addr=0xd0;
            request.data=0x00; add_req(&buffer,&request);
            request.addr=0xba;
            request.data=0x01; add_req(&buffer,&request);
            goto mcbcn;

         } else if(0==strcmp(command->argv[0],"zero")) {
            request.type=0;
            request.addr=0xb8;
            request.data=0x00; add_req(&buffer,&request);
            goto mcbcn;

         } else { 
             ierr = rec_dec(command->argv[0],&buffer,ip);
             kmove = TRUE;
             if (ierr!=0) goto error;
         }

parse:

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.rec;
      shm_addr->check.rec=0;

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
         if (kmove) {
            shm_addr->check.vkmove = FALSE;
            rte_rawt(&shm_addr->check.rc_mv_tm);
         }
         if (kenable)
            shm_addr->check.vkenable = FALSE;
         if (klowtape)
            shm_addr->check.vklowtape = FALSE;
         if (kload){
            shm_addr->check.vkload = TRUE;
            rte_rawt(&shm_addr->check.rc_ld_tm);
         }
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.rec=ichold;
      }

display:
      if(ip[2]<0) return;
      rec_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rc",2);
      return;
}
