/* mk5 bank_check SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256
#define BUFSIZE 512

void bank_check(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ierr, i, j;
      char *ptr;
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      struct rtime_mon rtime_mon;
      struct bank_set_mon bank_set_mon;
      int pong, active, inactive, itime[6];
      struct monit5_ping *old, *new;
      int ipass, done;
      int increment;
      char bank_warned[2];

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal == '=' ) {
	ierr=-301;
	goto error;
      }

/* if we get this far it is a set-up command so parse it */

      ipass=0;
parse:
      ipass++;
      out_recs=0;
      out_class=0;

      strcpy(outbuf,"rtime?\n");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      strcpy(outbuf,"bank_set?\n");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      if(ip[2]>=0)
	rtime_decode(&rtime_mon,&bank_set_mon,ip);

      rte_time(itime,itime+5);

      pong=shm_addr->monit5.pong%2;
      old=shm_addr->monit5.ping+pong;
      new=shm_addr->monit5.ping+1-pong;
      memcpy(new,old,sizeof(struct monit5_ping));

      new->active=-1;
      if(bank_set_mon.active_bank.state.known && ip[2]>=0) {
	if(strcmp(bank_set_mon.active_bank.active_bank,"A")==0)
	  new->active=0;
	else if(strcmp(bank_set_mon.active_bank.active_bank,"B")==0)
	  new->active=1;
      }

      active=new->active;
      if(active!=-1) {
	for(i=0;i<6;i++)
	  new->bank[active].itime[i]=itime[i];
	if(bank_set_mon.active_vsn.state.known)
	  strcpy(new->bank[active].vsn,bank_set_mon.active_vsn.active_vsn);
	else
	  new->bank[active].vsn[0]=0;
	if(rtime_mon.seconds.state.known)
	  new->bank[active].seconds=rtime_mon.seconds.seconds;
	else
	  new->bank[active].seconds=-1;
	if(rtime_mon.gb.state.known)
	  new->bank[active].gb=rtime_mon.gb.gb;
	else
	  new->bank[active].gb=-1;
	if(rtime_mon.percent.state.known)
	  new->bank[active].percent=rtime_mon.percent.percent;
	else
	  new->bank[active].percent=-1;
      }

      inactive=-1;
      if(bank_set_mon.inactive_bank.state.known && ip[2]>=0) {
	if(strcmp(bank_set_mon.inactive_bank.inactive_bank,"A")==0)
	  inactive=0;
	else if(strcmp(bank_set_mon.inactive_bank.inactive_bank,"B")==0)
	  inactive=1;
	if(inactive!=-1 && bank_set_mon.inactive_vsn.state.known) {
	  if(strcmp(new->bank[inactive].vsn,
		      bank_set_mon.inactive_vsn.inactive_vsn)!=0 ||
	     (new->bank[inactive].seconds==-1) &&
	     (new->bank[inactive].gb==-1) &&
	     (new->bank[inactive].percent==-1) ) {
	    for(i=0;i<6;i++)
	      new->bank[inactive].itime[i]=itime[i];
	    strcpy(new->bank[inactive].vsn,
		   bank_set_mon.inactive_vsn.inactive_vsn);
	    new->bank[inactive].seconds=-1;
	    new->bank[inactive].gb=-1;
	    new->bank[inactive].percent=-1;
	  }
	}
      }

      if(inactive == -1 && active!=-1) { /* nothing installed in inactive */
	inactive=1-active;
	for(i=0;i<6;i++)
	  new->bank[inactive].itime[i]=itime[i];
	new->bank[inactive].vsn[0]=0;
	new->bank[inactive].seconds=-1;
	new->bank[inactive].gb=-1;
	new->bank[inactive].percent=-1;
      } else if(inactive == -1 && active == -1) { /*nothing in either bank */
	for (j=0;j<2;j++) {
	  for(i=0;i<6;i++)
	    new->bank[j].itime[i]=itime[i];
	  new->bank[j].vsn[0]=0;
	  new->bank[j].seconds=-1;
	  new->bank[j].gb=-1;
	  new->bank[j].percent=-1;
	}
      }

      pong=1-pong;
      shm_addr->monit5.pong=pong;

      if(ip[2]<0) { /* read failed, we are done */
	if(ip[1]!=0) {
	  cls_clr(ip[0]);
	  ip[1]=0;
	}
	return;
      }

      increment=FALSE;
      if((itask==8 && ipass <=2) || 
	 ((shm_addr->scan_name.duration > 0) &&
	  (rtime_mon.seconds.seconds < shm_addr->scan_name.duration+200.0 ||
	  (shm_addr->scan_name.continuous > 0 &&
	   rtime_mon.seconds.seconds < shm_addr->scan_name.continuous+200.0)) &&
	  ((shm_addr->equip.drive[shm_addr->select] == MK5 &&
	   shm_addr->equip.drive_type[shm_addr->select]== MK5B_BS)||
	  shm_addr->equip.drive[shm_addr->select] != MK5) )){
	long before, after;
	unsigned isleep;

	increment=TRUE;
	out_recs=0;
	out_class=0;
	strcpy(outbuf,"bank_set=inc;\n");
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;

	ip[0]=1;
	ip[1]=out_class;
	ip[2]=out_recs;
	rte_rawt(&before);
	skd_run("mk5cn",'w',ip);
	skd_par(ip);

	if(ip[1]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	if(ip[2]<0) return;
       
	if(itask!=8 &&
	   strcmp(bank_warned,bank_set_mon.active_bank.active_bank)!=0) {
	  long ip[5];
	  char mess[80]="change_pack=";
	  strcat(mess,bank_set_mon.active_bank.active_bank);
	  strncpy(bank_warned,bank_set_mon.active_bank.active_bank,
		 sizeof(bank_warned));
	  strcat(mess,"/");

	  mess[strlen(mess)+8]=0;
	  strncat(mess,bank_set_mon.active_vsn.active_vsn,8);
	  
	  cls_snd( &(shm_addr->iclopr), mess, strlen(mess) , 0, 0);
	  skd_run("boss ",'n',ip);
	}

	/* wait 50 centiseconds before checking the first time */

	  rte_sleep(51);

	/* check for bank_set=inc completion */

	done=0;
	rte_rawt(&after);
	while((!done) && ((601-(after-before))>0)) {
	  bank_set_check(&done,ip);
	  if(ip[2]<0) {
	    if(ip[1]!=0) {
	      cls_clr(ip[0]);
	      ip[1]=0;
	    }
	    return;
	  }
	  if(done)
	    break;
	  rte_sleep(51);
	  rte_rawt(&after);
	}
      }

      if(itask==8) {
	if(ipass<=2)
	  goto parse;
        else {
	  int iwhich;
	  char output[MAX_OUT];
	  struct monit5_ping *ping;

	  cls_clr(ip[0]);
	  ping=shm_addr->monit5.ping+(shm_addr->monit5.pong)%2;
	  out_recs=0;
	  out_class=0;
	  for (i=0;i<2;i++) {
	    strcpy(output,command->name);
	    strcat(output,"/");
	    iwhich=(i+ping->active)%2;  /* i=1 active bank, i=2, inactive */
	    if(iwhich==0)
	      strcat(output,"a,");
	    else
	      strcat(output,"b,");
	  sprintf(output+strlen(output),"%s,",ping->bank[iwhich].vsn);
	  if(ping->bank[iwhich].seconds>=0.0)
	      sprintf(output+strlen(output),"%.1lf",
		      ping->bank[iwhich].seconds);
	    strcat(output,",");
	    if(ping->bank[iwhich].gb>=0.0)
	      sprintf(output+strlen(output),"%.3lf",
		      ping->bank[iwhich].gb);
	    strcat(output,",");
	    if(ping->bank[iwhich].percent>=0.0)
	      sprintf(output+strlen(output),"%.1lf",
		      ping->bank[iwhich].percent);
	    strcat(output,",");
	    if(ping->bank[iwhich].itime[0]>=0)
	      sprintf(output+strlen(output),"%2d:%.2d:%.2d",
		      ping->bank[iwhich].itime[3],
		      ping->bank[iwhich].itime[2],
		      ping->bank[iwhich].itime[1]);
	    cls_snd(&out_class,output,strlen(output),0,0);
	    out_recs++;
	  }
	  ip[0]=out_class;
	  ip[1]=out_recs;
	  ip[2]=ip[3]=ip[4]=0;
	  return;
	}
      } else if(itask==7 && ipass==1)
	goto parse;

      out_recs=0;
      out_class=0;

      strcpy(outbuf,"vsn?\n");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      strcpy(outbuf,"disk_serial?\n");
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

      bank_check_dis(command,itask,ip,increment);

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5b",2);
      return;
}

