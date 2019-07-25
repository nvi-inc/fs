/* vlba rec display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void rec_dis(command,ip)
struct cmd_ds *command;
long ip[5];
{
      int i, ierr, kcom;
      int totlen;
      struct res_buf buffer;
      struct res_rec response;
      void get_res(); void opn_res();
      char output[MAX_OUT];
      char feet[6];

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && (command->equal == '=')) {
         logmsg(output,command,ip);
         return;
      }
      else if (kcom) {
        ierr = -201;
        goto error;
      }
      else {

   /* format output buffer */

        strcpy(output,command->name);
        strcat(output,"/");
        opn_res(&buffer,ip);

        get_res(&response, &buffer);  /* 30 */
        sprintf(output+strlen(output),"%u",response.data);
        strcat(output,",");

        feet[0]='\0';
        int2str(feet,response.data,-5,1); 
        memcpy(shm_addr->LFEET_FS,feet,5);

        get_res(&response, &buffer);  /* 31 */
        totlen = response.data;
        sprintf(output+strlen(output),"%u",response.data);
        strcat(output,",");

        get_res(&response, &buffer);  /* 32 */
        sprintf(output+strlen(output),"%u",response.data);
        strcat(output,",");
        totlen+=response.data;
        sprintf(output+strlen(output),"%d",totlen);
        strcat(output,",");

        get_res(&response, &buffer);  /* 71 */
        sprintf(output+strlen(output),"%1.1x",response.data);
        strcat(output,",");

        if(response.state == -1) {
          clr_res(&buffer);
          ierr=-401;
          goto error;
        }
        clr_res(&buffer);
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
      memcpy(ip+3,"rc",2);
      return;
}
