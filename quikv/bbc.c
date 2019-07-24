/* vlba bbc snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"b1b2b3b4b5b6b7b8b9babbbcbdbebf"};
                       /* device menemonics */
                       /* -1 marks end of array only */
void bbc(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, count;
      char *ptr;
      struct req_rec request;      /* mcbcn request record */
      struct req_buf buffer;       /* mcbcn request buffer */
      struct bbc_cmd lcl;          /* local instance of bbc command struct */

      int bbc_dec();               /* parsing utilities */
      char *arg_next();

      void bbc00mc(), bbc01mc(), bbc02mc();    /* bbc utilities */
      void bbc03mc(), bbc05mc();
      void bbc_dis();
      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check value holder */

      ini_req(&buffer);

      ind=itask-1;                    /* index for this module */

      request.device[0]=device[ind*2];    /* device mnemonic */
      request.device[1]=device[ind*2+1];

      if (command->equal != '=') {            /* read module */
         request.type=1;
         request.addr=0x00; add_req(&buffer,&request);
         request.addr=0x01; add_req(&buffer,&request);
         request.addr=0x02; add_req(&buffer,&request);
         request.addr=0x03; add_req(&buffer,&request);
         request.addr=0x04; add_req(&buffer,&request);
         request.addr=0x05; add_req(&buffer,&request);
         request.addr=0x06; add_req(&buffer,&request);
         request.addr=0x07; add_req(&buffer,&request);
         goto mcbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) /* special cases */
         if (*command->argv[0]=='?') {
            bbc_dis(command,itask,ip);
            return;
         } else if(0==strcmp(command->argv[0],ADDR)) {
            request.type=2; add_req(&buffer,&request);
            goto mcbcn;
         } else if(0==strcmp(command->argv[0],TEST)) {
            request.type=4; add_req(&buffer,&request);
            goto mcbcn;
         } 

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->bbc[ind],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=bbc_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.bbc[ind];
      shm_addr->check.bbc[ind]=0;
      memcpy(&shm_addr->bbc[ind],&lcl,sizeof(lcl));
      
/* format buffers for mcbcn */
      
      request.type=0; 
      request.addr=0x00;
      bbc00mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x01;
      bbc01mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x02;
      bbc02mc(&request.data,&lcl); add_req(&buffer,&request);

      request.addr=0x03;
      bbc03mc(&request.data,&lcl); add_req(&buffer,&request);

/* the gain control values are treated here */
/*      request.addr=0x05;
      bbc05mc(&request.data,&lcl); add_req(&buffer,&request);
*/

mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
         shm_addr->check.bbc[ind]=ichold;
         rte_rawt(shm_addr->check.bbc_time+ind);
      }
         
      if (ichold >= 0)
         shm_addr->check.bbc[ind]=ichold % 1000 + 1;

      if(ip[2]<0) return;
      bbc_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vb",2);
      return;
}
