/* dbbcform snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbcform(command,ip)
struct cmd_ds *command;                /* parsed command structure */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr,count;
      char *ptr;
      struct dbbcform_cmd lcl;  /* local instance of dbbcform command struct */
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      int dbbcform_dec();               /* parsing utilities */
      char *arg_next();

      void dbbcform_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {            /* read module */
	out_recs=0;
	out_class=0;

	strcpy(outbuf,"dbbcform");
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
         goto dbbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  dbbcform_dis(command,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dbbcform,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbcform_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      if(ierr==0 && shm_addr->dbbcddcv<104 && lcl.mode == 5) {
	  ierr=-301;
	  goto error;
      }
      memcpy(&shm_addr->dbbcform,&lcl,sizeof(lcl));
      
/* format buffer for dbbcn */
      
      out_recs=0;
      out_class=0;
      strcpy(outbuf,"version");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      dbbcform_2_dbbc(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

dbbcn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(command->equal == '=' && -201 == ip[2]) {
	  logitn(NULL,ip[2],ip+3,ip[4]);
	  ip[2]=-302;
	  memcpy(ip+3,"df",2);
	}
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }

      dbbcform_dis(command,ip);
      return;
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"df",2);
      return;
}
