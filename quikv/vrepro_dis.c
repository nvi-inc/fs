/* vlba repro function display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void vrepro_dis(command,itask,ip,indx)
struct cmd_ds *command;
int itask,indx;
int ip[5];
{
      struct vrepro_cmd lclc;
      int ind,kcom,i,ich, ierr, count;
      struct res_buf buffer;
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
         memcpy(&lclc,shm_addr->vrepro+indx,sizeof(lclc));
      else {
         opn_res(&buffer,ip);
         get_res(&response, &buffer); mc98vrepro(&lclc, response.data);
         get_res(&response, &buffer); mc99vrepro(&lclc, response.data);

         get_res(&response, &buffer); 
	 if(lclc.head[0]==1) 
	   mc90vrepro(&lclc, response.data);

         get_res(&response, &buffer);
	 if(lclc.head[1]==1) 
	   mc91vrepro(&lclc, response.data);

	 if(shm_addr->equip.drive[indx] == VLBA4||
	    (shm_addr->equip.drive[indx]==VLBA &&
	     shm_addr->equip.drive_type[indx]==VLBAB)) {
	   get_res(&response, &buffer); 
	   if(lclc.head[0]==2) 
	     mc92vrepro(&lclc, response.data);

	   get_res(&response, &buffer);
	   if(lclc.head[1]==2) 
	     mc93vrepro(&lclc, response.data);
	 }

         get_res(&response, &buffer);
	 if(lclc.head[0]==1) 
	   mc94vrepro(&lclc, response.data);

         get_res(&response, &buffer);
	 if(lclc.head[1]==1) 
	   mc95vrepro(&lclc, response.data);

	 if(shm_addr->equip.drive[indx] == VLBA4||
	    (shm_addr->equip.drive[indx]==VLBA &&
	     shm_addr->equip.drive_type[indx]==VLBAB)) {
	   get_res(&response, &buffer);
	   if(lclc.head[0]==2) 
	     mc96vrepro(&lclc, response.data);

	   get_res(&response, &buffer);
	   if(lclc.head[1]==2) 
	     mc97vrepro(&lclc, response.data);
	 }

         get_res(&response, &buffer); mca8vrepro(&lclc, response.data);

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
        vrepro_enc(output,&count,&lclc);
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
      memcpy(ip+3,"vr",2);
      return;
}
