/* vlba tape display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

void tape_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      struct tape_cmd lclc;
      struct tape_mon lclm;
      int ind,kcom,i,ich, ierr, count;
      struct res_buf buffer;
      struct res_rec response;
      void get_res();
      void mcb6tape(), mc30tape(), mc33tape(), mc57tape();
      void mc72tape(), mc73tape(), mc74tape();

      char output[MAX_OUT];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmsg(output,command,ip);
         return;
      }
      else if (kcom) {
         memcpy(&lclc,&shm_addr->lowtp,sizeof(lclc));
      }
      else {
         opn_res(&buffer,ip);
         get_res(&response, &buffer); mcb6tape(&lclc, response.data);
         get_res(&response, &buffer); mc30tape(&lclm, response.data);
         get_res(&response, &buffer); mc33tape(&lclm, response.data);
	 if(shm_addr->equip.drive_type != VLBA2)
	   get_res(&response, &buffer); mc57tape(&lclm, response.data);
         get_res(&response, &buffer); mc72tape(&lclm, response.data);
         get_res(&response, &buffer); mc73tape(&lclm, response.data);
         get_res(&response, &buffer); mc74tape(&lclm, response.data);
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
        tape_enc(output,&count,&lclc);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          tape_mon(output,&count,&lclm);
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
      memcpy(ip+3,"vt",2);
      return;
}
