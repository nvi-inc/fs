/* mk6_record SNAP command display */

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

void mk6_record_dis(command,itask,iwhich,ip,out_class,out_recs)
struct cmd_ds *command;
int itask, iwhich;
int ip[5];
int *out_class;
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
      struct mk6_record_cmd lclc;
      struct mk6_record_mon lclm;
      char who[3];

      snprintf(who,3,"c%c",unit_letters[iwhich]);

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if((!kcom) && command->equal == '=') {
	if(0!=logm6msg(output,command,itask,iwhich,ip,out_class,out_recs)) {
	  ip[2]=-400;
	  memcpy(ip+3,"3r",2);
	  memcpy(ip+4,who,2);
	  return;
	}
	ip[2]=0;
	return;
      } else if(kcom) {
         memcpy(&lclc,&shm_addr->mk6_record[itask],sizeof(lclc));
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
	  if(i==0)
	    if(0!=m6_2_mk6_record(inbuf,&lclc,&lclm,ip,who)) {
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
        mk6_record_enc(output,&count,&lclc);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          mk6_record_mon(output,&count,&lclm);
        }
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
      memcpy(ip+3,"3r",2);
      memcpy(ip+4,who,2);
error:
      cls_clr(iclass);
      return;
}


