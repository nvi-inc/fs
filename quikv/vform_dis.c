/* vlba formatter display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void vform_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      struct vform_cmd lclc;
      struct vform_mon lclm;
      int ind,kcom,i,j,ich, ierr, count, itracks[ 32];
      unsigned aux_data[28][4];
      struct res_buf buff_out;
      struct res_rec response;
      void get_res();
      char output[MAX_OUT];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmsg(output,command,ip);
         return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->vform,sizeof(lclc));
      else {
         opn_res(&buff_out,ip);
         get_res(&response,&buff_out);
         get_res(&response,&buff_out);

         for(i=0;i<32;i++) {                  /* get the track assignments */
             get_res(&response,&buff_out);
             itracks[i]=response.data;
         }
         mcD2vform(&lclc,itracks);
         get_res(&response,&buff_out); mc20vform(&lclm,response.data);
         get_res(&response,&buff_out); mc21vform(&lclm,response.data);
         get_res(&response,&buff_out); mc22vform(&lclm,response.data);
         get_res(&response,&buff_out); mc23vform(&lclm,response.data);
         get_res(&response,&buff_out); mc24vform(&lclm,response.data);
         get_res(&response,&buff_out); mc60vform(&lclm,response.data);
         shm_addr->form_version=lclm.version;
         get_res(&response,&buff_out); mc8Dvform(&lclc,response.data);
         get_res(&response,&buff_out); mc8Evform(&lclc,response.data);
         get_res(&response,&buff_out); mc8Fvform(&lclc,response.data);
         get_res(&response,&buff_out); mc90vform(&lclc,response.data);
         get_res(&response,&buff_out); mc91vform(&lclc,response.data);
         get_res(&response,&buff_out); mc99vform(&lclc,response.data);
         get_res(&response,&buff_out); mc9Avform(&lclc,response.data);
         get_res(&response,&buff_out); mcADvform(&lclc,response.data);

         goto skip_aux;
         for (i=0;i<28;i++) {                   /* 28 tracks of aux data */
           get_res(&response,&buff_out);
           get_res(&response,&buff_out);

           for (j=0;j<4;j++) {                  /* 3 words per track */
              get_res(&response,&buff_out);
              aux_data[i][j]=response.data;
           }
         }
         mcD6vform(&lclc,aux_data);

skip_aux:
         if(response.state == -1) {
            clr_res(&buff_out);
            ierr=-401;
            goto error;
         }
         clr_res(&buff_out);
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        vform_enc(output,&count,&lclc);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          vform_mon(output,&count,&lclm);
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
      memcpy(ip+3,"vf",2);
      return;
}
