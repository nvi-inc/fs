/* scan_name snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

void scan_name(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ierr, i;
      char output[MAX_OUT];

      if (command->equal != '=' ||
	  (command->argv[1]==NULL && command->argv[0]!=NULL &&
	   strcmp(command->argv[0],"?")==0)) {
	/* format output buffer */

	strcpy(output,command->name);
	strcat(output,"/");
	strcat(output,shm_addr->scan_name);
	for (i=0;i<5;i++) ip[i]=0;
	cls_snd(&ip[0],output,strlen(output),0,0);
	ip[1]++;
	return;
      } else if (command->argv[0]==NULL) {
	ierr=-101;
	printf(" in no arg\n");	goto error;
      } else if (strcmp(command->argv[0],"*")==0) {
	ierr=-301;
	goto error;
      } else if (strlen(command->argv[0])>sizeof(shm_addr->scan_name)-1) {
	ierr=-201;
	goto error;
      }
      strcpy(shm_addr->scan_name,command->argv[0]);
	
/* all parameters parsed okay, update common */

      
      ip[0]=ip[1]=ierr=0;
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ws",2);
      return;
}
