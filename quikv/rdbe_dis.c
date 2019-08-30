/* rdbe SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 2048
#define BUFSIZE 2049
extern char unit_letters[];

void rdbe_dis(command,itask,iwhich,ip,out_class,out_recs)
struct cmd_ds *command;
int itask,iwhich;
long ip[5];
long *out_class;
int *out_recs;
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      char inbuf[BUFSIZE],*first;
      int n;
      char who[3];

   /* format output buffer */

      if(itask == 0)
	sprintf(output,"%s%c",command->name,unit_letters[iwhich]);
      else
	strcpy(output,command->name);

      strcat(output,"/");
      start=output+strlen(output);

      for (i=0;i<ip[1];i++) {
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -401;
	  goto error;
	}
	inbuf[nchars]=0;

	first=inbuf;
	while(strlen(first)>0) {
	  *start=0;
	  if(strlen(first)+1<=sizeof(output)-strlen(output)) {
	    strcpy(start,first);
	    if(strlen(output)>0 && output[strlen(output)-1]=='\n')
	      output[strlen(output)-1]='\0';
	    first+=strlen(first);
	  } else {
	    int last;
	    n=sizeof(output)-strlen(output)-1;
	    for(last=n;last>(n-35) && last>0;last--) {
	      if(first[last-1]==':') {
		n=last;
		break;
	      }
	    }
	    if(index(":",first[n-1])==NULL)
	      for(last=n;last>(n-35) && last>0;last--) {
		if(first[last-1]==',') {
		  n=last;
		  break;
		}
	      }
	    if(index(":,",first[n-1])==NULL)
	      for(last=n;last>(n-35) && last>1;last--) {
		if(first[last-1]==' ') {
		  n=last-1;
		  break;
		}
	      }
	    strncpy(start,first,n);
	    start[n]=0;
	    first+=n;
	  }
	  if(strlen(start)>0) {
	    cls_snd(out_class,output,strlen(output),0,0);
	    (*out_recs)++;
	  }
	}
      }

      return;

error:
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=0;
      if(ip[2]!=0)
	logit(NULL,ip[2],ip+3);
      ip[2]=ierr;
      memcpy(ip+3,"2m",2);
      snprintf(who,3,"c%c",unit_letters[iwhich]);
      memcpy(ip+4,who,2);
      return;
}
