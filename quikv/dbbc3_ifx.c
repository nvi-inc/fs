/* dbbc3 ifX snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc3_ifx(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, count;
      char *ptr;
      struct dbbc3_ifx_cmd lcl;     /* local instance of dbbcnn command struct */
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      int dbbc3_ifx_dec();               /* parsing utilities */
      char *arg_next();

      void dbbc3_ifx_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */
      static char ifx[] = {"abcdefgh"};


      ind=itask-1;                    /* index for this module */

      if(ind>=shm_addr->dbbc3_ddc_ifs) {
	ierr=-300;
	goto error;
      }

      if (command->equal != '=') {            /* read module */
	out_recs=0;
	out_class=0;

	sprintf(outbuf,"dbbcif%c",ifx[ind]);
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
         goto dbbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  dbbc3_ifx_dis(command,itask,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dbbc3_ifx[ind],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbc3_ifx_dec(&lcl,&count, ptr,itask);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->dbbc3_ifx[ind],&lcl,sizeof(lcl));
      
/* format buffer for dbbcn */
      
      out_recs=0;
      out_class=0;
      ifx_2_dbbc3(outbuf,itask,&lcl);

      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

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

      dbbc3_ifx_dis(command,itask,ip);
      return;
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"dj",2);
      return;
}
