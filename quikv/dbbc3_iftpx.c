/* dbbc3 iftpx snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc3_iftpx(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, count;
      char *ptr;

      int out_recs, out_class;
      char outbuf[BUFSIZE];

      void dbbc3_iftpx_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */
      static char ifx[] = {"abcdefgh"};


      ind=itask-11;                    /* index for this module */

      if(ind>=shm_addr->dbbc3_ddc_ifs) {
	ierr=-300;
	goto error;
      }

      if (command->equal != '=') {            /* read module */
	out_recs=0;
	out_class=0;

	sprintf(outbuf,"dbbctp%c",ifx[ind]);
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
         goto dbbcn;
      } else {
	ierr=-301;
	goto error;
      }

dbbcn:
      ip[0]=8;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }

      dbbc3_iftpx_dis(command,itask,ip);
      return;
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"dt",2);
      return;
}
