/* save_file snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <stdio.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void save_file(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr, multi;
      char *ptr;
      FILE *fptr;
      char file[65],buffer[513],*mode;

      char *arg_next();

      if (command->equal != '=' || command->argv[0]==NULL) {
	/* no first parameter */
	ierr=-301;
	goto error;
      } else if (command->argv[1]==NULL) { /* special cases */
	strcpy(file,FS_ROOT);
	strcat(file,"/control/");
	if(command->argv[0][0]=='+') {
	  strncat(file,command->argv[0]+1,sizeof(file)-strlen(file)-1);
	  multi=TRUE;
	} else {
	  strncat(file,command->argv[0],sizeof(file)-strlen(file)-1);
	  multi=FALSE;
	}
	if( NULL == (fptr=fopen(file,"r"))) {
	  logit(NULL,errno,"un");
	  ierr=-301;
	  goto error;
	}
	if(NULL == fgets(buffer,sizeof(buffer),fptr) && !feof(fptr)) {
	  logit(NULL,errno,"un");
	  ierr=-302;
	  goto error;
	} else if (feof(fptr)) {
	  ierr=-309;
	  goto error;
	}
	if(strlen(buffer)>0 && buffer[strlen(buffer)-1] == '\n')
	  buffer[strlen(buffer)-1] = 0;
	if(strlen(buffer)>0) {
	  cls_snd( &(shm_addr->iclopr), buffer, strlen(buffer), 0, 0);
	  skd_run("boss ",'n',ip);
	}
	while(multi && !feof(fptr) ){
	  if(NULL == fgets(buffer,sizeof(buffer),fptr) && !feof(fptr)) {
	    logit(NULL,errno,"un");
	    ierr=-302;
	    goto error;
	  }
	  if(!feof(fptr)) {
	    if(strlen(buffer)>0 && buffer[strlen(buffer)-1] == '\n')
	      buffer[strlen(buffer)-1] = 0;
	    if(strlen(buffer)>0) {
	      cls_snd( &(shm_addr->iclopr), buffer, strlen(buffer), 0, 0);
	      skd_run("boss ",'n',ip);
	    }
	  }
	}
	if(0!=fclose(fptr)) {
	  logit(NULL,errno,"un");
	  ierr=-303;
	  goto error;
	}
      } else {
	strcpy(file,FS_ROOT);
	strcat(file,"/control/");
	if(command->argv[0][0]=='+') {
	  strncat(file,command->argv[0]+1,sizeof(file)-strlen(file)-1);
	  multi=TRUE;
	  mode="a";
	} else {
	  strncat(file,command->argv[0],sizeof(file)-strlen(file)-1);
	  multi=FALSE;
	  mode="w";
	}
	if( NULL == (fptr=fopen(file,mode))) {
	  logit(NULL,errno,"un");
	  ierr=-305;
	  goto error;
	}
	if ( 0 != chmod(file,0666)) {
	  logit(NULL,errno,"un");
	  ierr=-306;
	  goto error;
	}
	if(0 > fputs(command->argv[1],fptr)) {
	  logit(NULL,errno,"un");
	  ierr=-307;
	  goto error;
	}
	if(0 > fputs("\n",fptr)) {
	  logit(NULL,errno,"un");
	  ierr=-307;
	  goto error;
	}
	if(0!=fclose(fptr)) {
	  logit(NULL,errno,"un");
	  ierr=-308;
	  goto error;
	}
      }
      ierr=0;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"sf",2);
      return;
}
