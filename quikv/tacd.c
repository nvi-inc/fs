/* tacd snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>


#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void tacd(command,itask,ip)
struct cmd_ds *command;                /* command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ierr, i;
      char *reset_host;

      void tacd_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */

      /*shm_addr->tacd.continuous=0;*/

      if (command->equal != '=') {           /* run tacd */
	if(shm_addr->tacd.display==0){
	   command->argv[0]="status";
	}
	else if(shm_addr->tacd.display==1){
	   command->argv[0]="time";
	}
	else {
	   command->argv[0]="average";
	}
	tacd_dis(command,itask,ip);
	return;
      } else if (command->argv[0]==NULL) {
	shm_addr->tacd.continuous=0;
	skd_run("tacd",'n',ip);
	ip[0]=ip[1]=ip[2]=0;
	return;
      } else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"status")){
	  shm_addr->tacd.display=0;
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"version")){
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"cont")){
	  shm_addr->tacd.continuous=1;
	  skd_run("tacd",'n',ip);
	  ip[0]=ip[1]=ip[2]=0;
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"single")){
	  shm_addr->tacd.continuous=0;
	  skd_run("tacd",'n',ip);
	  ip[0]=ip[1]=ip[2]=0;
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"time")){
	  shm_addr->tacd.display=1;
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"average")){
	  shm_addr->tacd.display=2;
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"stop")){
	  shm_addr->tacd.continuous=0;
	  shm_addr->tacd.stop_request=1;
	  skd_run("tacd",'n',ip);
	  ip[0]=ip[1]=ip[2]=0;
          tacd_dis(command,itask,ip);
	  return;
	} else if(!strcmp(command->argv[0],"start")){
	  shm_addr->tacd.continuous=0;
	  shm_addr->tacd.stop_request=-1;
	  shm_addr->tacd.display=2;
	  skd_run("tacd",'n',ip);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
	} else {
	  ierr=-201;
	  goto error;
	}
      }

      ip[0]=ip[1]=ip[2]=0;
      return;
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ta",2);
      return;
}


