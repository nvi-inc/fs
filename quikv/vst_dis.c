/* vlba vst display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void vst_dis(command,ip,indx)
struct cmd_ds *command;
int ip[5];
int indx;
{
      struct vst_cmd lclc;
      int kcom, i, ierr, count;
      struct res_buf buffer;
      struct res_rec response;
      void get_res();
      char output[MAX_OUT];

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmsg(output,command,ip);
         return;
      } else if (kcom){
         lclc.dir = shm_addr->idirtp[indx];
         lclc.speed = shm_addr->ispeed[indx];
	 lclc.cips = shm_addr->cips[indx];
         lclc.rec = shm_addr->venable[indx].general;
      } else {
         opn_res(&buffer,ip);
         get_res(&response, &buffer); mcb5vst(&lclc, response.data);
         lclc.rec = shm_addr->venable[indx].general;
         get_res(&response, &buffer); mcb1vst(&lclc, response.data);
         if(response.state == -1) {
            clr_res(&buffer);
            ierr=-401;
            goto error;
         }
         clr_res(&buffer);
      }


   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        vst_enc(output,&count,&lclc);
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
      memcpy(ip+3,"vs",2);
      return;
}
