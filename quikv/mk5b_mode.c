/* mk5b_mode SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void mk5b_mode(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      struct mk5b_mode_cmd lcl;
      int increment;

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {
	if(13 == itask) {
	  char *str;
	  out_recs=0;
	  out_class=0;
	  str="mode?\n";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;
	  goto mk5cn;
	} else {
	  command->argv[1]=NULL;
	  command->argv[0]="?";
	  mk5b_mode_dis(command,itask,ip);
	  return;
	}
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  mk5b_mode_dis(command,itask,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      m5state_init(&lcl.source.state);
      m5state_init(&lcl.mask.state);
      m5state_init(&lcl.decimate.state);
      m5state_init(&lcl.fpdp.state);
      m5state_init(&lcl.disk.state);

      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->mk5b_mode,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=mk5b_mode_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      if(shm_addr->disk_record.record.record==1 &&
	 shm_addr->disk_record.record.state.known==1)
	if(lcl.disk.disk!=0 && lcl.disk.state.known==1) {
	  ierr=-301;
	  goto error;
	}
	  
      memcpy(&shm_addr->mk5b_mode,&lcl,sizeof(lcl));
      
      if(13!=itask) {
	ip[0]=ip[1]=ip[3]=0;
	return;
      }

      out_recs=0;
      out_class=0;

      mk5b_mode_2_m5(outbuf,&lcl);

      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

mk5cn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }
      mk5b_mode_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5t",2);
      return;
}
