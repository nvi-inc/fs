/* mk5 scan_check SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void scan_check_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      long out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      struct scan_check_mon lclm;
      long class, nrecs;

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=output+strlen(output);
      
      class=ip[0];
      nrecs=ip[1];

      for (i=0;i<nrecs;i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(class,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ip[3] = -401;
	  goto error;
	}
	if(i==0)
	  if(0!=m5_2_scan_check(inbuf,&lclm,ip)) {
	    cls_clr(class);
	    return;
	  }
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        scan_check_mon(output,&count,&lclm);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;

      if((lclm.mode.state.error || (!lclm.mode.state.known)
	  || strcmp("?",lclm.mode.mode)==0))
	logit(NULL,-601,"5k");

      return;

error:
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5k",2);
      return;
}
