/* vlba capture display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void capture_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      struct capture_mon lclm;
      int ind,kcom,i,ich, ierr, count;
      struct res_buf buffer;
      struct res_rec response;
      void get_res();
      char output[MAX_OUT];

         lclm.qa.drive=shm_addr->vform.qa.drive;
         lclm.qa.chan=shm_addr->vform.qa.chan;
         
         opn_res(&buffer,ip);
         get_res(&response, &buffer);
         get_res(&response, &buffer); mc48capture(&lclm,response.data);
         get_res(&response, &buffer); mc49capture(&lclm,response.data);
         get_res(&response, &buffer); mc4Acapture(&lclm,response.data);
         get_res(&response, &buffer); mc4Bcapture(&lclm,response.data);

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
        capture_mon(output,&count,&lclm);
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
      memcpy(ip+3,"vc",2);
      return;
}
