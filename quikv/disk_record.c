/* mk5 disk_record SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void disk_record(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      struct disk_record_cmd lcl;
      int increment;

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=' ) {
	char *str;
	out_recs=0;
	out_class=0;
	str="record?\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	goto mk5cn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  disk_record_dis(command,itask,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->disk_record,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=disk_record_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->disk_record,&lcl,sizeof(lcl));
      
      out_recs=0;
      out_class=0;

      disk_record_2_m5(outbuf,&lcl);

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
      disk_record_dis(command,itask,ip);
      if(ip[2]<0)
	return;

      if((command->equal != '=' && lcl.record.record== 0) && 
	 (shm_addr->equip.drive[shm_addr->select]!=MK5 ||
	 (shm_addr->equip.drive[shm_addr->select] == MK5 &&
	  shm_addr->equip.drive_type[shm_addr->select]== MK5A))) {

	cls_clr(ip[0]);

	out_recs=0;
	out_class=0;

	strcpy(outbuf,"vsn?\n");
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
	
	strcpy(outbuf,"disk_serial?\n");
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;

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
	increment=FALSE;
	bank_check_dis(command,itask,ip,increment);
      }
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5r",2);
      return;
}
