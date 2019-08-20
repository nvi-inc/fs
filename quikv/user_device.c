/* user_device snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void user_device(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct user_device_cmd lcl;

      int user_device_dec();                 /* parsing utilities */
      char *arg_next();

      void user_device_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {           /* read module */
	  user_device_dis(command,ip);
	  return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          user_device_dis(command,ip);
          return;
	}
    
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->user_device,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=user_device_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->user_device,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=ierr=0;
      user_device_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q-",2);
      return;
}
