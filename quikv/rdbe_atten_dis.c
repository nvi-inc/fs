/* rdbe_atten SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

extern char unit_letters[];

void rdbe_atten_dis(command,itask,iwhich,ip,out_class,out_recs)
struct cmd_ds *command;
int itask, iwhich;
long ip[5];
long *out_class;
int *out_recs;
{
      int ierr, count, i;
      char output[MAX_OUT];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      char inbuf[BUFSIZE];
      int kcom;
      int iclass, nrecs;
      struct rdbe_atten_cmd lclc;
      char who[3];

      if(itask == 0)
	sprintf(output,"%s%c",command->name,unit_letters[iwhich]);
      else
	strcpy(output,command->name);

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if((!kcom) && command->equal == '=') {
	if(0!=logmsg_rdbe(output,command,itask,iwhich,ip,out_class,out_recs)) {
	  ip[2]=-400;
	  memcpy(ip+3,"3r",2);
	  memcpy(ip+4,who,2);
	  return;
	}
	ip[2]=0;
	return;
      } else if(kcom) {
         memcpy(&lclc,&shm_addr->rdbe_atten[itask],sizeof(lclc));
      } else {
	iclass=ip[0];
	nrecs=ip[1];
	for (i=0;i<nrecs;i++) {
	  char *ptr;
	  if ((nchars =
	       cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	    ierr = -401-i;
	    goto error2;
	  }
	  if(i==0)
	    if(0!=rdbe_2_rdbe_atten0(inbuf,&lclc,ip,who)) {
	      goto error;
	    }
	  if(i==1)
	    if(0!=rdbe_2_rdbe_atten1(inbuf,&lclc,ip,who)) {
	      goto error;
	    }
	}
      }

   /* format output buffer */

      if(itask == 0 && iwhich!=0)
	sprintf(output,"%s%c",command->name,unit_letters[iwhich]);
      else
	strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        rdbe_atten_enc(output,&count,&lclc);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(out_class,output,strlen(output),0,0);
      (*out_recs)++;
      return;

error2:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"2b",2);
      memcpy(ip+4,who,2);
error:
      cls_clr(iclass);
      return;
}


