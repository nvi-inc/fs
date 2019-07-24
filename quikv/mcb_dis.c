/* vlba mcb SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void mcb_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      int ierr, count, i;
      struct res_buf buffer;
      struct res_rec response;
      struct mcb_mon lclm;
      void get_res();
      char output[MAX_OUT];

      if (command->argv[2] != NULL) {   /* it was a command request */
         logmsg(output,command,ip);
         return;
      }

/* it is a monitor request so log the data */

      opn_res(&buffer,ip);
      get_res(&response, &buffer); lclm.data=response.data;
      if(response.state == -1) {
         clr_res(&buffer);
         ierr=-401;
         goto error;
       }
      clr_res(&buffer);

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        mcb_mon(output,&count,&lclm);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vm",2);
      return;
}
