/* mk6_active SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void mk6_active(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
  int ilast, ierr, i, lens, arg;
  char *ptr;
  char *arg_next();
  int out_recs, out_class;
  char output[BUFSIZE];
  int local[MAX_MK6];

  out_class=0;
  out_recs=0;
  
  if (command->equal != '=' ) {
    strcpy(output,command->name);
    strcat(output,"/");
    lens=strlen(output);
    for(i=0;i<MAX_MK6;i++)
	if(shm_addr->mk6_active[i])
	  snprintf(output+strlen(output),3,"%d,",i+1);
    if(lens==strlen(output))
      strcat(output,",");
    else
      output[strlen(output)-1]=0;
    cls_snd(&out_class,output,strlen(output),0,0);
    out_recs++;
    
    ip[0]=out_class;
    ip[1]=out_recs;
    ip[2]=0;
    return;
  }

/* if we get this far it is a set-up command so parse it */

parse:
  ilast=0;                                      /* last argv examined */
  ptr=arg_next(command,&ilast);
  for (i=0;i<MAX_MK6;i++)
    local[i]=0;
  
  while( ptr != NULL) {
    if(1!=sscanf(ptr,"%d",&arg)) {
      ierr=-301;
      goto error;
    } else if(arg <= 0 || arg > MAX_MK6) {
      ierr=-302;
      goto error;
    } else
      local[arg-1]=1;
    ptr=arg_next(command,&ilast);
  }
  
  memcpy(shm_addr->mk6_active,local,sizeof(shm_addr->mk6_active));
  ierr=0;
  
 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"3a",2);
  ip[4]=MAX_MK6;
  return;
}
