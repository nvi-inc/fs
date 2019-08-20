/* dbbcgain display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 513

int logmsg_dbbc();

void dbbcgain_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      struct dbbcgain_cmd lclc;
      struct dbbcgain_mon lclm;
      int ind,kcom,i,ich, ierr, count;
      char output[MAX_OUT];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      char inbuf[BUFSIZE];
      char inbuf2[BUFSIZE];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         ierr=logmsg_dbbc(output,command,ip);
	 if(ierr!=0) {
	   ierr+=-450;
	    goto error2;
	 }
	 return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->dbbcgain,sizeof(lclc));
      else {
	for (i=0;i<ip[1];i++) {
	  if ((nchars =
	       cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	    if(i<ip[1]-1) 
	      cls_clr(ip[0]);
	    ierr =  -401;
	    goto error;
	  }
	  inbuf[nchars]=0;
	  memcpy(inbuf2,inbuf,sizeof(inbuf2));
	  if(i==0)
	    ierr=dbbc_2_dbbcgain(&lclc,&lclm,inbuf);
	  if(ierr!=0) {
	    if(i<ip[1]-1) 
	      cls_clr(ip[0]);
	    ierr=-403;
	    logite(inbuf2,-402,"dg");
	    goto error;
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
        dbbcgain_enc(output,&count,&lclc);
      }

      if(!kcom) {
	count=0;
	while( count>= 0) {
	  if (count > 0) strcat(output,",");
	  count++;
	  dbbcgain_mon(output,&count,&lclm);
	}
      }
      
      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;
      return;

error:
      ip[0]=0;
      ip[1]=0;
 error2:
      ip[2]=ierr;
      memcpy(ip+3,"di",2);
      return;
}
