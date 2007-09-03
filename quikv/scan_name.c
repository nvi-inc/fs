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
	strcat(output,shm_addr->scan_name.station);
	strcat(output,",");
	if(shm_addr->scan_name.duration > 0)
	  sprintf(output+strlen(output),"%ld",shm_addr->scan_name.duration);
	strcat(output,",");
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

      /* set defaults for early exit for NULL on any remaining args */

      shm_addr->scan_name.session[0]=0;
      shm_addr->scan_name.station[0]=0;
      shm_addr->scan_name.duration=-1;
      shm_addr->scan_name.continuous=-1;

      if (command->argv[1]==NULL) {
	shm_addr->scan_name.session[0]=0;  /*redundant, included for clarity */
	goto done;
      } else if (strcmp(command->argv[1],"*")==0) {
	ierr=-302;
	goto error;
      } else if (strlen(command->argv[1])>
		 sizeof(shm_addr->scan_name.session)-1) {
	ierr=-202;
	goto error;
      } else
	strcpy(shm_addr->scan_name.session,command->argv[1]);

      if (command->argv[2]==NULL) {
	shm_addr->scan_name.station[0]=0;  /*redundant, included for clarity */
	goto done;
      } else if (strcmp(command->argv[2],"*")==0) {
	ierr=-303;
	goto error;
      } else if (strlen(command->argv[2])>
		 sizeof(shm_addr->scan_name.station)-1) {
	ierr=-203;
	goto error;
      } else
	strcpy(shm_addr->scan_name.station,command->argv[2]);

      if (command->argv[3]==NULL) {
	shm_addr->scan_name.duration=-1;  /*redundant, included for clarity */
	goto done;
      } else if (strcmp(command->argv[3],"*")==0) {
	ierr=-304;
	goto error;
      } else if
	(1!=sscanf(command->argv[3],"%ld",&shm_addr->scan_name.duration)||
	 shm_addr->scan_name.duration < 0){
	ierr=-204;
	printf(" argv[3] '%s' strlen %d\n",command->argv[3],
	       strlen(command->argv[3]));
	goto error;
      }

      if (command->argv[4]==NULL) {
	shm_addr->scan_name.continuous=-1; /*redundant, included for clarity */
	goto done;
      } else if (strcmp(command->argv[4],"*")==0) {
	ierr=-305;
	goto error;
      } else if
	(1!=sscanf(command->argv[4],"%ld",&shm_addr->scan_name.continuous)||
	 shm_addr->scan_name.continuous < 0){
	ierr=-205;
	goto error;
      }
	
/* all parameters parsed okay, update common */
 done:
      ip[0]=ip[1]=ip[2]=ierr=0;
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ws",2);
      return;
}
