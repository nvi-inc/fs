/* mark IV pcalports display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define MAX_BUF 256

void pcalports_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      struct pcalports_cmd lclc;
      int ind,kcom,i,j,ich, ierr, count, nrec, nchar, idum;
      long iclass;

      char output[MAX_OUT];
      char buff[MAX_BUF];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmatmsg(output,command,ip);
         return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->pcalports,sizeof(lclc));
      else {
	ierr=-402;
	goto error;
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        pcalports_enc(output,&count,&lclc);
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
      memcpy(ip+3,"pp",2);
      return;
}
