/* mk5 disk2file SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void disk2file(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      struct disk2file_cmd lcl;

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=' ) {
	char *str;
	out_recs=0;
	out_class=0;
	str="disk2file?\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	str="scan_set?\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	ip[0]=1;
	goto mk5cn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  disk2file_dis(command,itask,ip);
	  return;
	} else if(strcmp(command->argv[0],"abort")==0) {
	  char *str;
	  out_recs=0;
	  out_class=0;
	  str="reset=abort\n";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;
	  ip[0]=5;
	  goto mk5cn;
	}
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->disk2file,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=disk2file_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->disk2file,&lcl,sizeof(lcl));
      
      out_recs=0;
      out_class=0;

      disk2file_2_m5_scan_set(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      disk2file_2_m5(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;
      ip[0]=1;

mk5cn:
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
      disk2file_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5f",2);
      return;
}
