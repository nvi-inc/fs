/* mark IV tracks snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void tracks4(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, i, count;
      char *ptr;
      struct form4_cmd lcl;     /* local instance of form4 command struc */

      int tracks4_dec();                 /* parsing utilities */
      char *arg_next();

      void tracks4_dis();

      ierr = 0;
      memcpy(&lcl,&shm_addr->form4,sizeof(lcl));

      if (command->equal != '=') {            /* display table */
	 tracks4_dis(command,&shm_addr->form4,ip);
	 return;
      } else if (command->argv[0]==NULL) { /* simple equals */
	lcl.enable[0] = 0;
	lcl.enable[1] = 0;
        goto copy;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=tracks4_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */
copy:
      memcpy(&shm_addr->form4,&lcl,sizeof(lcl));
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"4n",2);
      return;
}
