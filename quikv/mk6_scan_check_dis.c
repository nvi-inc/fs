/* mk6 scan_check SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void mk6_scan_check_dis(command,itask,iwhich,ip,out_class,out_recs)
struct cmd_ds *command;
int itask, iwhich;
int ip[5];
int *out_class;
int *out_recs;
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      char inbuf[BUFSIZE];
      struct mk6_scan_check_mon lclm;
      int class, nrecs;
      char *params;
      char what[3];

      snprintf(what,3,"c%d",iwhich);

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
	  ierr = -401;
	  goto error;
	}
	if(i==0)
	  if(0!=m5_2_mk6_scan_check(inbuf,&lclm,ip,what)) {
	    cls_clr(class);
	    shm_addr->mk6_last_check[iwhich=1].ip2=ip[2];
	    memcpy(shm_addr->mk6_last_check[iwhich-1].who,ip+3,2);
	    shm_addr->mk6_last_check[iwhich-1].who[2]=0;
	    memcpy(shm_addr->mk6_last_check[iwhich-1].what,ip+4,2);
	    shm_addr->mk6_last_check[iwhich-1].what[2]=0;
	    return;
	  }
      }

   /* format output buffer */

      if(itask == 0 && iwhich!=0)
	sprintf(output,"%s%d",command->name,iwhich);
      else
	strcpy(output,command->name);
      strcat(output,"/");
      params=output+strlen(output);

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        mk6_scan_check_mon(output,&count,&lclm);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(out_class,output,strlen(output),0,0);
      (*out_recs)++;

      /* copy into last_check structure */
      
      append_safe(shm_addr->mk6_last_check[iwhich-1].string,",",
		  sizeof(shm_addr->mk6_last_check[iwhich-1].string));

      append_safe(shm_addr->mk6_last_check[iwhich-1].string,params,
		  sizeof(shm_addr->mk6_last_check[iwhich-1].string));

      if(lclm.type.state.error || (!lclm.type.state.known)
	 || strcmp("?",lclm.type.type)==0) {
	logita(NULL,-601,"3k",what);
	shm_addr->mk6_last_check[iwhich-1].ip2=-601;
	strncpy(shm_addr->mk6_last_check[iwhich-1].who,"3k",
		sizeof(shm_addr->mk6_last_check[iwhich-1].who));
	shm_addr->mk6_last_check[iwhich-1].who
	  [sizeof(shm_addr->mk6_last_check[iwhich-1].who)-1]=0;
	memcpy(shm_addr->mk6_last_check[iwhich-1].what,what,2);
	shm_addr->mk6_last_check[iwhich-1].what[2]=0;
      }

      if(lclm.missing.state.error || (!lclm.missing.state.known)
	 || lclm.missing.missing !=0 ) {
	logita(NULL,-602,"3k",what);
	  shm_addr->mk6_last_check[iwhich-1].ip2=-602;
	  strncpy(shm_addr->mk6_last_check[iwhich-1].who,"3k",
		  sizeof(shm_addr->mk6_last_check[iwhich-1].who));
	  shm_addr->mk6_last_check[iwhich-1].who
	    [sizeof(shm_addr->mk6_last_check[iwhich-1].who)-1]=0;
	memcpy(shm_addr->mk6_last_check[iwhich-1].what,what,2);
	shm_addr->mk6_last_check[iwhich-1].what[2]=0;
      }

      if(lclm.error.state.known || lclm.error.state.error) {
	logita(NULL,-603,"3k",what);
	  shm_addr->mk6_last_check[iwhich-1].ip2=-603;
	  strncpy(shm_addr->mk6_last_check[iwhich-1].who,"3k",
		  sizeof(shm_addr->mk6_last_check[iwhich-1].who));
	  shm_addr->mk6_last_check[iwhich-1].who
	    [sizeof(shm_addr->mk6_last_check[iwhich-1].who)-1]=0;
	memcpy(shm_addr->mk6_last_check[iwhich-1].what,what,2);
	shm_addr->mk6_last_check[iwhich-1].what[2]=0;
      }

      return;

error:
      cls_clr(class);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"3k",2);
      memcpy(ip+4,what,2);

      shm_addr->mk6_last_check[iwhich-1].ip2=ip[2];
      memcpy(shm_addr->mk6_last_check[iwhich-1].who,ip+3,2);
      shm_addr->mk6_last_check[iwhich-1].who[2]=0;
      memcpy(shm_addr->mk6_last_check[iwhich-1].what,what,2);
      shm_addr->mk6_last_check[iwhich-1].what[2]=0;
      return;
}
