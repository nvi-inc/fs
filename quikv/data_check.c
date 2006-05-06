/* mk5 data_check SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void data_check(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      void skd_run(), skd_par();      /* program scheduling utilities */

      shm_addr->last_check.string[0]=0;
      append_safe(shm_addr->last_check.string,command->name,
		  sizeof(shm_addr->last_check.string));
      shm_addr->last_check.ip2=0;

      if (command->equal == '=' ) {
	ierr=-301;
	goto error;
      }

      if(data_check_pos(ip)!=0)
	return;

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      out_recs=0;
      out_class=0;

      strcpy(outbuf,"data_check?\n");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;
      
mk5cn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	shm_addr->last_check.ip2=ip[2];
	memcpy(shm_addr->last_check.who,ip+3,2);
	shm_addr->last_check.who[2]=0;
	return;
      }
      data_check_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5d",2);

      shm_addr->last_check.ip2=ip[2];
      memcpy(shm_addr->last_check.who,ip+3,2);
      shm_addr->last_check.who[2]=0;
      return;
}
