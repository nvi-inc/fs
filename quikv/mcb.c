/* vlba mcb SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mcb(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      struct req_rec request;          /* mcbcn request record */
      struct req_buf buffer;           /* mcbcn request buffer */
      struct mcb_cmd lcl;
      char *arg_next();

      void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_req(&buffer);

      if (command->equal != '=' ||
          command->argv[0]==NULL ||
          command->argv[1]==NULL || 
          ! ( command->argv[2]==NULL ||
              command->argv[3]==NULL    )
         ) {
         ierr=-301;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=mcb_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* format buffers for mcbcn */
      
      if( memcmp(lcl.device,"\0",2)==0){    /* absolute address */
         request.type=6;
         if(lcl.cmd) {
           lcl.addr|=0x8000;
           request.data=lcl.data;
         } else
           request.data=0;
      } else {
         memcpy(request.device,lcl.device,2);
         if(lcl.cmd){
           request.type=0;
           request.data=lcl.data;
         } else
           request.type=1; 
      }

      request.addr=lcl.addr;
      add_req(&buffer,&request);
mcbcn:
      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) return;
      mcb_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vm",2);
      return;
}
