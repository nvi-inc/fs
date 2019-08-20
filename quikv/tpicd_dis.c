/* tpicd display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void tpicd_dis(command,ip)
struct cmd_ds *command;
int ip[5];
{
      struct tpicd_cmd lclc;
      int kcom, i, ierr, count, start;
      char output[MAX_OUT];

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         return;
      } else if (kcom){
	memcpy(&lclc,&shm_addr->tpicd,sizeof(lclc));
      } else {
	memcpy(&lclc,&shm_addr->tpicd,sizeof(lclc));
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=strlen(output);

      for (i=0;i<5;i++) ip[i]=0;

      count=0;
      while( count>= 0) {
	count++;
        tpicd_enc(output,&count,&lclc);

	if(count > 0) {
	  cls_snd(&ip[0],output,strlen(output),0,0);
	  ip[1]++;
	  output[start]='\0';
	}
      }
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"tc",2);
      return;
}
