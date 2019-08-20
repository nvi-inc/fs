/* S2 recorder label display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void s2label_dis(command,ip)
struct cmd_ds *command;
int ip[5];
{
      struct s2label_cmd lclc;
      int kcom, i, ierr, count, start;
      struct rclcn_res_buf buffer;
      char output[MAX_OUT];

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logrclmsg(output,command,ip);
         return;
      } else if (kcom){
	memcpy(&lclc,&shm_addr->s2label,sizeof(lclc));
      } else {
	opn_rclcn_res(&buffer,ip);

	ierr=get_rclcn_tapeid_read(&buffer,lclc.tapeid);
	if(ierr!=0)
	  goto error;

	ierr=get_rclcn_tapetype_read(&buffer,lclc.tapetype);
	if(ierr!=0)
	  goto error;

	lclc.format[0]=0;

	clr_rclcn_res(&buffer);
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=strlen(output);

      for (i=0;i<5;i++) ip[i]=0;

      count=0;
      while( count>= 0) {
        if (count != 0)
	  strcat(output,",");
        count++;
        s2label_enc(output,&count,&lclc);
      }
      if(strlen(output)>0) output[strlen(output)-1]='\0';

      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]++;

      return;

error:
      clr_rclcn_res(&buffer);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rb",2);
      return;
}
