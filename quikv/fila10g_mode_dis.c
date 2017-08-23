/* fila10g_mode SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void fila10g_mode_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      long out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      int kcom;
      int iclass, nrecs;
      struct fila10g_mode_cmd lclc;
      struct fila10g_mode_mon lclm;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if((!kcom) && command->equal == '=') {
         ierr=logmsg_dbbc(output,command,ip);
	 if(ierr!=0) {
	   ierr=-400;
	   goto error;
	 }
	return;
      } else if(kcom) {
         memcpy(&lclc,&shm_addr->fila10g_mode,sizeof(lclc));
      } else {
	iclass=ip[0];
	nrecs=ip[1];
	for (i=0;i<nrecs;i++) {
	  char *ptr;
	  if ((nchars =
	       cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	    ierr = -401;
	    goto error2;
	  }
	  if(i==0) {
	    if(0!=fila10g_2_vsi_bitmask(inbuf,&lclc)) {
	      ierr=-501;
	      goto error2;
	    }
	  } else if(i==1) {
	    if(0!=fila10g_2_vsi_samplerate(inbuf,&lclc,&lclm)) {
	      ierr=-502;
	      goto error;
	    }
	  }
	}
      }
   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        fila10g_mode_enc(output,&count,&lclc);
      }

      /* this a rare command that has a monitor '?' value from shared memory */
	 
      if(kcom) {
	m5state_init(&lclm.clockrate.state);
	lclm.clockrate.clockrate=shm_addr->m5b_crate*1.0e6+0.5;
	lclm.clockrate.state.known=1;
      }
      count=0;
      while( count>= 0) {
	if (count > 0) strcat(output,",");
	count++;
	fila10g_mode_mon(output,&count,&lclm);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;
      return;

error2:
      cls_clr(iclass);
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"dh",2);
      return;
}


