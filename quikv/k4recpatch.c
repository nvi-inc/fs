/* K4 recpatch snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void k4recpatch(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, i, count;
      char *ptr;
      struct k4recpatch_cmd lcl;/* local instance of k4recpatch command struc */

      int k4recpatch_dec();                 /* parsing utilities */
      char *arg_next();

      void k4recpatch_dis();

      ierr = 0;
      memcpy(&lcl,&shm_addr->k4recpatch,sizeof(lcl));

      if (command->equal != '=' ||
	  (command->argv[0]!=NULL && strcmp(command->argv[0],"?")==0)) {
	/* display table */
	 k4recpatch_dis(command,&shm_addr->k4recpatch,ip);
	 return;
      } else if (command->argv[0]==NULL) { /* simple equals */
	for (i=0;i<16;i++) 
	  lcl.ports[i]=0;
        goto copy;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=k4recpatch_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */
copy:
      memcpy(&shm_addr->k4recpatch,&lcl,sizeof(lcl));
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"kp",2);
      return;
}
