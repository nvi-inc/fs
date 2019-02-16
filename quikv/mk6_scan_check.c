/* mk6 scan_check SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void mk6_scan_check(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
  int ilast, ierr, ind, i, count, j;
      char *ptr;
      char *arg_next();
      int out_recs[MAX_MK6], out_class[MAX_MK6];
      char outbuf[BUFSIZE];
      int iplast[5];
      int iwhich;
      int rtn_class=0;
      int rtn_recs=0;
      int some;

      void skd_run(), skd_par();      /* program scheduling utilities */

      some=FALSE;
      for (i=0;i<MAX_MK6;i++)
	if(shm_addr->mk6_active[i]!=0){
	  some=TRUE;
	  break;
	}

      if(!some) {
	ierr=-302;
	goto error;
      }

      shm_addr->last_check.string[0]=0;
      append_safe(shm_addr->last_check.string,command->name,
		  sizeof(shm_addr->last_check.string));
      shm_addr->last_check.ip2=0;

      if (command->equal == '=' ) {
	ierr=-301;
	goto error;
      }


/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      for (i=0;i<MAX_MK6;i++)
	if(itask == i+1 || shm_addr->mk6_active[i]!=0 && itask ==0 ) {
	  out_recs[i]=0;
	  out_class[i]=0;
	}

      strcpy(outbuf,"scan_check?;\n");
      for (i=0;i<MAX_MK6;i++)
	if(itask == i+1 || shm_addr->mk6_active[i]!=0 && itask ==0 ) {
	  cls_snd(&out_class[i], outbuf, strlen(outbuf) , 0, 0);
	  out_recs[i]++;
	}
      
mk6cn:
      for (i=0;i<MAX_MK6;i++)
	if(itask == i+1 || shm_addr->mk6_active[i]!=0 && itask == 0) {
	  char name[6];
	  ip[0]=1;
	  ip[1]=out_class[i];
	  ip[2]=out_recs[i];
	  sprintf(name,"mk6c%1.1d",i+1);
	  iwhich=i+1;
	  skd_run_p(name,'p',ip,&iwhich); /* from here until the last
                                            skd_run_p(NULL,'w',...) is
                                            processed, we have to handle
                                            errors locally, no passing up
                                            i.e. too hard to unwind */
	}
      for(j=0;j<5;j++)
	iplast[j]=0;

      for (i=0;i<MAX_MK6;i++)
	if(itask == i+1 || shm_addr->mk6_active[i]!=0 && itask == 0) {
	  skd_run_p(NULL,'w',ip,&iwhich);
	  skd_par(ip);
	  if(ip[2]<0) {
	    if(ip[0]!=0) {
	      cls_clr(ip[0]);
	      ip[0]=ip[1]=0;
	    }
	  } else
	    mk6_scan_check_dis(command,itask,iwhich,ip,&rtn_class,&rtn_recs);
	  if(itask !=0)
	    continue;

	  if(ip[2]!=0 && iplast[2]!=0) {
	    logita(NULL,iplast[2],iplast+3,iplast+4);
	  }
	  if(ip[2]!=0) {
	    shm_addr->mk6_last_check[iwhich-1].ip2=ip[2];
	    memcpy(shm_addr->mk6_last_check[iwhich-1].who,ip+3,2);
	    shm_addr->mk6_last_check[iwhich-1].who[2]=0;
	    memcpy(shm_addr->mk6_last_check[iwhich-1].what,ip+4,2);
	    shm_addr->mk6_last_check[iwhich-1].what[2]=0;
	    
	    for(j=2;j<5;j++)
	      iplast[j]=ip[j];
	  }
	}
                                 /* local error processing no longer require */
      if(iplast[2]!=0)
	for(j=2;j<5;j++)
	  ip[j]=iplast[j];

      ip[0]=rtn_class;
      ip[1]=rtn_recs;

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"3k",2);

      return;
}
