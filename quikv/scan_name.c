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
	strcat(output,shm_addr->scan_name.name);
	strcat(output,",");
	strcat(output,shm_addr->scan_name.session);
	strcat(output,",");
	if(shm_addr->scan_name.duration > 0)
	  sprintf(output+strlen(output),"%ld",shm_addr->scan_name.duration);
	if(shm_addr->scan_name.continuous > 0)
	  sprintf(output+strlen(output),"%ld",shm_addr->scan_name.continuous);
	for (i=0;i<5;i++) ip[i]=0;
	cls_snd(&ip[0],output,strlen(output),0,0);
	ip[1]++;
	return;
      } else if (command->argv[0]==NULL) {
	ierr=-101;
	goto error;
      } else if (strcmp(command->argv[0],"*")==0) {
	ierr=-301;
	goto error;
      } else if (strlen(command->argv[0])>sizeof(shm_addr->scan_name.name)-1) {
	ierr=-201;
	goto error;
      }
      strcpy(shm_addr->scan_name.name,command->argv[0]);

      if (command->argv[0]==NULL||command->argv[1]==NULL) {
	shm_addr->scan_name.session[0]=0;
      } else if (strcmp(command->argv[1],"*")==0) {
	ierr=-302;
	goto error;
      } else if (strlen(command->argv[1])>
		 sizeof(shm_addr->scan_name.session)-1) {
	ierr=-202;
	goto error;
      } else
	strcpy(shm_addr->scan_name.session,command->argv[1]);

      if (command->argv[0]==NULL||command->argv[1]==NULL||
	  command->argv[2]==NULL) {
	shm_addr->scan_name.duration=-1;
      } else if (strcmp(command->argv[2],"*")==0) {
	ierr=-303;
	goto error;
      } else if
	(1!=sscanf(command->argv[2],"%ld",&shm_addr->scan_name.duration)||
	 shm_addr->scan_name.duration < 0){
	ierr=-203;
	goto error;
      }

      if (command->argv[0]==NULL||command->argv[1]==NULL||
	  command->argv[2]==NULL ||command->argv[3]==NULL) {
	shm_addr->scan_name.continuous=-1;
      } else if (strcmp(command->argv[2],"*")==0) {
	ierr=-304;
	goto error;
      } else if
	(1!=sscanf(command->argv[3],"%ld",&shm_addr->scan_name.continuous)||
	 shm_addr->scan_name.continuous < 0){
	ierr=-204;
	goto error;
      }
	
/* all parameters parsed okay, update common */
      
      ip[0]=ip[1]=ip[2]=ierr=0;
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ws",2);
      return;
}
