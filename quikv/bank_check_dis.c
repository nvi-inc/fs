/* mk5 bank_check SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void bank_check_dis(command,itask,ip)
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
      int len;

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=output+strlen(output);

      for (i=0;i<ip[1];i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ip[3] = -401;
	  goto error;
	}
	
	ptr=strchr(inbuf,'=');
	if(ptr == NULL) {
	  ptr=strchr(inbuf,' ');
	}  
	if(ptr == NULL) {
	  if(strlen(inbuf)+1<=sizeof(output)-strlen(output)) {
	    strcpy(start,inbuf);
	    if(strlen(output)>0)
	      output[strlen(output)-1]='\0';
	  } else {
	    strncpy(start,inbuf,sizeof(output)-strlen(output)-1);
	    output[sizeof(output)]=0;
	  }
	} else {
	  if(1!=sscanf(ptr+1,"%d",&ierr)){
	    ierr=-301;
	    goto error;
	  } else if(ierr != 0) {
	    logita(NULL,-900-ierr,"m5","  ");
	    ierr=-304;
	    goto error;
	  } else {
	    ptr=strchr(inbuf,':');
	    if(ptr==NULL) {
	      ierr=-303;
	      goto error;
	    }
	    ptr=strtok(ptr+1," ");
	    while (ptr!=NULL && strcmp(ptr,";")!=0) {
	      if (strcmp(ptr,":")!=0) {
		if(i==0) {
		  len=sizeof(shm_addr->mk5vsn)-1;
		  if(!(strncmp(ptr,shm_addr->mk5vsn,len)!=0 ||
		       shm_addr->mk5vsn_logchg != shm_addr->logchg)) {
		    cls_clr(ip[0]);
		    goto done;
		  }
		  len=strlen(ptr);
		  strncat(output,ptr,len);
		  strncpy(shm_addr->mk5vsn,ptr,sizeof(shm_addr->mk5vsn));
		  shm_addr->mk5vsn_logchg = shm_addr->logchg;
		  if(len>sizeof(shm_addr->mk5vsn)-1)
		    shm_addr->mk5vsn[sizeof(shm_addr->mk5vsn)-1]=0;
		} else {
		  strcat(output,",");
		  len=strlen(ptr);
		  strncat(output,ptr,len);
		}
	      }
	      ptr=strtok(NULL," ");
	    }
	  }
	}
      }
      cls_snd(&out_class,output,strlen(output),0,0);
      out_recs++;

 done:
      ip[0]=out_class;
      ip[1]=out_recs;
      ip[2]=0;

      return;

error:
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5b",2);
      return;
}
