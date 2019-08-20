/* vlba bit_density snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void bit_density(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, indx, ichold, i, count;
      char *ptr;
      int lcl;        /* local instance of bit_density command struc */

      int bit_density_dec();                 /* parsing utilities */
      char *arg_next();

      indx=itask-1;                    /* index for this module */

      ierr = 0;
      if (command->equal != '=') {            /* read module */
        bit_density_dis(command,itask,ip,indx);
	return;
      } 

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->bit_density[indx],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=bit_density_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->bit_density[indx],&lcl,sizeof(lcl));
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"vd",2);
      return;
}
