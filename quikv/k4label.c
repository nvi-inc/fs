/* k4 label snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void k4label(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct k4label_cmd lcl;

      int k4label_dec();                 /* parsing utilities */
      char *arg_next();

      void k4label_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {           /* read module */
	  k4label_dis(command,ip);
	  return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          k4label_dis(command,ip);
          return;
	}
    
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->k4label,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=k4label_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->k4label,&lcl,sizeof(lcl));

      /* allow schedule to continue */

      shm_addr->KHALT=0;

      ip[0]=ip[1]=ierr=0;

      k4label_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ka",2);
      return;
}
