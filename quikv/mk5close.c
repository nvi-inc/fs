/* mk5close SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void mk5close(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal == '=' ) {
	ierr=-301;
	goto error;
      }

/* if we get this far it is a set-up command so parse it */

mk5cn:
      ip[0]=3;
      ip[1]=0;
      ip[2]=0;
      if(itask == 6)
	skd_run("mk5cn",'w',ip);
      else // (itask == 28)
	skd_run("dbbcn",'w',ip);
      skd_par(ip);

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5c",2);
      return;
}
