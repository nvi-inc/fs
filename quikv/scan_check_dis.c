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
int ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      int out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      struct scan_check_mon lclm;
      int class, nrecs;
      char *params;

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
	  if(0!=m5_2_scan_check(inbuf,&lclm,ip)) {
	    cls_clr(class);
	    shm_addr->last_check.ip2=ip[2];
	    memcpy(shm_addr->last_check.who,ip+3,2);
	    shm_addr->last_check.who[2]=0;
	    return;
	  }
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      params=output+strlen(output);

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

      /* copy into last_check structure */
      
      append_safe(shm_addr->last_check.string,",",
		  sizeof(shm_addr->last_check.string));

      append_safe(shm_addr->last_check.string,params,
		  sizeof(shm_addr->last_check.string));

      if(shm_addr->equip.drive[0] == MK5 &&
	 (shm_addr->equip.drive_type[0] ==MK5B ||
	  shm_addr->equip.drive_type[0] == MK5B_BS ||
	  shm_addr->equip.drive_type[0] ==MK5C ||
	  shm_addr->equip.drive_type[0] == MK5C_BS ||
	  shm_addr->equip.drive_type[0] == FLEXBUFF )
	 ) {
	if(lclm.type.state.error || (!lclm.type.state.known)
	    || strcmp("?",lclm.type.type)==0) {
	  logit(NULL,-601,"5k");
	  shm_addr->last_check.ip2=-601;
	  strncpy(shm_addr->last_check.who,"5k",
		  sizeof(shm_addr->last_check.who));
	  shm_addr->last_check.who[sizeof(shm_addr->last_check.who)-1]=0;
	  return;
	}
      } else {
	if(lclm.mode.state.error || (!lclm.mode.state.known)
	    || strcmp("?",lclm.mode.mode)==0) {
	  logit(NULL,-601,"5k");
	  shm_addr->last_check.ip2=-601;
	  strncpy(shm_addr->last_check.who,"5k",
		  sizeof(shm_addr->last_check.who));
	  shm_addr->last_check.who[sizeof(shm_addr->last_check.who)-1]=0;
	  return;
	}
      }
      if(lclm.missing.state.error || (!lclm.missing.state.known)
	 || lclm.missing.missing !=0 ) {
	if(!(shm_addr->equip.drive[0] == MK5 &&
	     (shm_addr->equip.drive_type[0] == MK5C ||
	      shm_addr->equip.drive_type[0] == MK5C_BS ||
	      shm_addr->equip.drive_type[0] == FLEXBUFF))
	   ) {
	  logit(NULL,-602,"5k");
	  shm_addr->last_check.ip2=-602;
	} else {
	  logit(NULL,602,"5k");
	  shm_addr->last_check.ip2=602;
	}
	strncpy(shm_addr->last_check.who,"5k",
		sizeof(shm_addr->last_check.who));
	shm_addr->last_check.who[sizeof(shm_addr->last_check.who)-1]=0;
      }

      return;

error:
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5k",2);

      shm_addr->last_check.ip2=ip[2];
      memcpy(shm_addr->last_check.who,ip+3,2);
      shm_addr->last_check.who[2]=0;
      return;
}
