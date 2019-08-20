/* mk5 SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void mk5(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=' ||
          command->argv[0]==NULL )
         {
         ierr=-301;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      out_recs=0;
      out_class=0;
      ptr=arg_next(command,&ilast);

      while( ptr != NULL) {
	strcpy(outbuf,ptr);
	strcat(outbuf,"\n");
	cls_snd(&out_class, outbuf, strlen(outbuf), 0, 0);
	out_recs++;
	ptr=arg_next(command,&ilast);
      }

mk5cn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      mk5_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5m",2);
      return;
}
