/* vlba bbc display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void bbc_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      struct bbc_cmd lclc;
      struct bbc_mon lclm;
      int ind,kcom,i,ich, ierr, count;
      struct res_buf buffer;
      struct res_rec response;
      void get_res();
      void mc00bbc(), mc01bbc(), mc02bbc(), mc03bbc();
      void mc04bbc(), mc05bbc(), mc06bbc(), mc07bbc();
      char output[MAX_OUT];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmsg(output,command,ip);
         return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->bbc[ind],sizeof(lclc));
      else {
         opn_res(&buffer,ip);
         get_res(&response, &buffer); mc00bbc(&lclc, response.data);
         get_res(&response, &buffer); mc01bbc(&lclc, response.data);
         get_res(&response, &buffer); mc02bbc(&lclc, response.data);
         get_res(&response, &buffer); mc03bbc(&lclc, response.data);
         get_res(&response, &buffer); mc04bbc(&lclm, response.data);
         get_res(&response, &buffer); mc05bbc(&lclc, response.data);
         get_res(&response, &buffer); mc06bbc(&lclm, response.data);
         get_res(&response, &buffer); mc07bbc(&lclm, response.data);
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
        bbc_enc(output,&count,&lclc);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          bbc_mon(output,&count,&lclm);
        }
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
      memcpy(ip+3,"vb",2);
      return;
}
