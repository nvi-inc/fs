/* dbbcNN snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbcnn(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, count;
      char *ptr;
      struct dbbcnn_cmd lcl;      /* local instance of dbbcnn command struct */
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      int dbbcnn_dec();               /* parsing utilities */
      char *arg_next();

      void dbbcnn_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */

      if(DBBC_DDC != shm_addr->equip.rack_type &&
	 DBBC_DDC_FILA10G != shm_addr->equip.rack_type) {
	ierr=-501;
	goto error;
      }

      ind=itask-1;                    /* index for this converter */

      if(1==ind%2 &&  NULL != index("ef",shm_addr->dbbcddcvl[0])) {
	ierr=-301;
	goto error;
      }

      if (command->equal != '=') {            /* read module */
	out_recs=0;
	out_class=0;

	sprintf(outbuf,"dbbc%02.2d",itask);
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
         goto dbbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  dbbcnn_dis(command,itask,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dbbcnn[ind],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbcnn_dec(&lcl,&count, ptr,itask);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->dbbcnn[ind],&lcl,sizeof(lcl));
      
/* format buffer for dbbcn */
      
      out_recs=0;
      out_class=0;
      dbbcnn_2_dbbc(outbuf,itask,&lcl);

      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

dbbcn:
      ip[0]=1;
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

      dbbcnn_dis(command,itask,ip);
      return;
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"dc",2);
      return;
	}
