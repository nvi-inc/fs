/* getfila10gtime.c - get fila10g formatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "fmset.h"
#include "fila10g_cfg.h"

extern int ip[5];           /* parameters for fs communications */
extern unsigned char outbuf[512];     /* class i-o buffer */
extern int synch;
extern int rack, rack_type;
extern int m5b_crate;
extern int dbbcddcv;

extern dbbc_sync;
extern WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
extern struct fila10g_cfg *fila10g_cfg_use;

extern iDBBC;

void rte2secs();

void getfila10gtime(unixtime,unixhs,fstime,fshs,formtime,formhs)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
{
	int centisec[6], centiavg, centidiff, hsdiff;
        int it[6], sleep;
	struct tm *formtm;
	char *str;
	char *name;
	int out_recs;
	int out_class;
	int decimate;
	char buff[80];
        int formtime32;
        int fstime32;

	if(synch) {
	  int i, iwait;

	  iwait=0;
	  synch=0;
	  mvwaddstr( maindisp, 4, 10+15,
		     "                                       ");
	  mvwaddstr( maindisp, 4, 10+15+39 , "               ");
	  mvwaddstr( maindisp, 5, 10+15,
		     "                                       ");
	  mvwaddstr( maindisp, 5, 10+15+39 , "               ");
	  mvwaddstr( maindisp, 6, 10+15,
		     "                                       ");
	  mvwaddstr( maindisp, 6, 10+15+39 , "               ");

	  if(rack == DBBC && rack_type == DBBC_DDC_FILA10G &&
             dbbcddcv>=107) {
	    out_recs=0;
	    out_class=0;

	    sprintf(buff,"vsi_clk=%d",m5b_crate);
	    cls_snd(&out_class, buff, strlen(buff) , 0, 0);
	    out_recs++;
	    sprintf(buff,"DBBC vsi_clk (%d MHz) command sent.",m5b_crate);
	    logit(buff,0,NULL);

	    ip[0]=1;
	    ip[1]=out_class;
	    ip[2]=out_recs;
	  
	    nsem_take("fsctl",0);
	    name="dbbcn";
	    while(skd_run_to(name,'w',ip,120)==1) {
	      if (nsem_test("fs   ") != 1) {
		endwin();
		fprintf(stderr,"Field System not running - fmset aborting\n");
		rte_sleep(SLEEP_TIME);
		exit(0);
	      }
	      name=NULL;
	    }
	    skd_par(ip);
	    nsem_put("fsctl");
	    if(ip[1]!=0)
	      cls_clr(ip[0]);
	    if(ip[2] != 0) {
	      logita(NULL,ip[2],ip+3,ip+4);
	      logit(NULL,-9,"fv");
	      *formtime=-1;
	      return;
	    }
	    rte_sleep(150); 
	  }

	  if(rack == DBBC && dbbc_sync) {
	    dbbc_sync=0;
	    out_recs=0;
	    out_class=0;

	    str="pps_sync";
	    cls_snd(&out_class, str, strlen(str) , 0, 0);
	    out_recs++;
	    if(0==iDBBC)
	      logit("DBBC sync command sent.",0,NULL);
	    else if (1==iDBBC)
	      logit("DBBC#1 sync command sent.",0,NULL);
	    else
	      logit("DBBC#2 sync command sent.",0,NULL);

	    ip[0]=1;
	    ip[1]=out_class;
	    ip[2]=out_recs;
	  
	    nsem_take("fsctl",0);
	    if(2!=iDBBC)
	      name="dbbcn";
	    else
	      name="dbbc2";
	    while(skd_run_to(name,'w',ip,120)==1) {
	      if (nsem_test("fs   ") != 1) {
		endwin();
		fprintf(stderr,"Field System not running - fmset aborting\n");
		rte_sleep(SLEEP_TIME);
		exit(0);
	      }
	      name=NULL;
	    }

	    skd_par(ip);
	    nsem_put("fsctl");
	    if(ip[1]!=0)
	      cls_clr(ip[0]);
	    if(ip[2] != 0) {
	      logita(NULL,ip[2],ip+3,ip+4);
	      logit(NULL,-9,"fv");
	      *formtime=-1;
	      return;
	    }

	    wstandout(maindisp);
	    mvwaddstr( maindisp, 4, 25, "Waiting for DBBC ");
	    leaveok ( maindisp, FALSE); /* leave cursor in place */
	    wrefresh ( maindisp );
	    for(i=0;i<2;i++) {  /*wait for 2nd next 1 PPS before continuing */
	      rte_sleep(100); 
	      mvwaddstr( maindisp, 4,25+17+i, ".");
	      leaveok ( maindisp, FALSE); /* leave cursor in place */
	      wrefresh ( maindisp );
	    }
	    rte_sleep(26);
	    mvwaddstr( maindisp, 4,25+17+i, " ");
	    iwait=1;

	  }

	  /* set config */

	  if(NULL==fila10g_cfg_use)
	  if(0==iDBBC) 
	    logit("No Fila10G configuration selected",0,NULL);
	  else if(1==iDBBC)
	    logit("No Fila10G#1 configuration selected",0,NULL);
	  else
	    logit("No Fila10G#2 configuration selected",0,NULL);
	  else {
	    struct fila10g_cmd *cmd;
	    int start;
	    if(0==iDBBC) 
	      sprintf(outbuf,"Fila10G configuration '%s' selected",
		      fila10g_cfg_use->name);
	    else if(1==iDBBC)
	      sprintf(outbuf,"Fila10G#1 configuration '%s' selected",
		      fila10g_cfg_use->name);
	    else
	      sprintf(outbuf,"Fila10G#2 configuration '%s' selected",
		      fila10g_cfg_use->name);

	    logit(outbuf,0,NULL);

	    cmd=fila10g_cfg_use->cmd;
	    fila10g_cfg_use=NULL;

	    while(NULL!=cmd) {
	      out_recs=0;
	      out_class=0;
	      if(0==iDBBC) 
		strcpy(outbuf,"Sending: '");
	      else if(1==iDBBC)
		strcpy(outbuf,"Sending FiLa10G#1: '");
	      else
		strcpy(outbuf,"Sending FiLa10G#2: '");
	      start=strlen(outbuf);
	      strcat(outbuf,"fila10g=");
	      strcat(outbuf,cmd->cmd);
	      strcat(outbuf,"'");
	      logit(outbuf,0,NULL);
	      cls_snd(&out_class, outbuf+start, strlen(outbuf+start)-1 , 0, 0);
	      out_recs++;

	      ip[0]=6;
	      ip[1]=out_class;
	      ip[2]=out_recs;
	      nsem_take("fsctl",0);
	      if(2!=iDBBC)
		name="dbbcn";
	      else
		name="dbbc2";
	      while(skd_run_to(name,'w',ip,120)==1) {
		if (nsem_test("fs   ") != 1) {
		  endwin();
		  fprintf(stderr,"Field System not running - fmset aborting\n");
		  rte_sleep(SLEEP_TIME);
		  exit(0);
		}
		name=NULL;
	      }
	      skd_par(ip);
	      nsem_put("fsctl");
	      
	      if(ip[1]!=0)
		cls_clr(ip[0]);
	      if(ip[2] != 0) {
		logita(NULL,ip[2],ip+3,ip+4);
		logit(NULL,-9,"fv");
		*formtime=-1;
		return;
	      }
	      cmd=cmd->next;
	    }

	  }

	  /* now set time */

	  out_recs=0;
	  out_class=0;
	  
	  { int ilast; 
	    char *plastp1;
	    plastp1=memchr(shm_addr->fila10gvsi_in,' ',
			   sizeof(shm_addr->fila10gvsi_in));
	    if(plastp1) 
	      ilast=plastp1-shm_addr->fila10gvsi_in;
	    else
	      ilast=sizeof(shm_addr->fila10gvsi_in);
	    sprintf(outbuf,"fila10g=inputselect %.*s",ilast,
		    shm_addr->fila10gvsi_in);
	  }
	  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	  out_recs++;

          decimate=1;
	  if(shm_addr->fila10g_mode.decimate.state.known)
	    decimate=shm_addr->fila10g_mode.decimate.decimate;

 	  sprintf(outbuf,"fila10g=vsi_samplerate %d %d",
		  (int) (shm_addr->m5b_crate*1.0e6+0.5),decimate);
	  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	  out_recs++;

	  str="fila10g=reset";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;

	  rte_time(it,it+5);
	  sleep=(120-it[0])%100;
	  rte_sleep(sleep);

	  rte_time(it,it+5);
	  rte2secs(it,formtime);

	  formtm=gmtime(formtime);
	  (void) strftime(outbuf,sizeof(outbuf),
		 "fila10g=timesync %Y-%m-%dT%H:%M:%S",formtm);
	  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	  out_recs++;
	  if(0==iDBBC) 
	    logit("FiLa10G sync command sent.",0,NULL);
	  else if(1==iDBBC)
	    logit("FiLa10G#1 sync command sent.",0,NULL);
	  else
	    logit("FiLa10G#2 sync command sent.",0,NULL);
	  ip[0]=6;
	  ip[1]=out_class;
	  ip[2]=out_recs;
	  
	  wstandout(maindisp);
	  mvwaddstr( maindisp, 4, 25+iwait*20, "Waiting for FiLa10G ");
	  leaveok ( maindisp, FALSE); /* leave cursor in place */
	  wrefresh ( maindisp );

	  nsem_take("fsctl",0);
	  if(2!=iDBBC)
	    name="dbbcn";
	  else
	    name="dbbc2";
	  while(skd_run_to(name,'w',ip,120)==1) {
	    if (nsem_test("fs   ") != 1) {
	      endwin();
	      fprintf(stderr,"Field System not running - fmset aborting\n");
	      rte_sleep(SLEEP_TIME);
	      exit(0);
	    }
	    name=NULL;
	  }
	  skd_par(ip);
	  nsem_put("fsctl");

	  if(ip[1]!=0)
	    cls_clr(ip[0]);
	  if(ip[2] != 0) {
	    logita(NULL,ip[2],ip+3,ip+4);
	    logit(NULL,-9,"fv");
	    *formtime=-1;
	    return;
	  }
	  for(i=0;i<1;i++) {  /*show we are doing something */
	    rte_sleep(100); 
	    mvwaddstr( maindisp, 4, 25+iwait*20+20+i, ".");
	    leaveok ( maindisp, FALSE); /* leave cursor in place */
	    wrefresh ( maindisp );
	  }
	  wstandend(maindisp);
	}

	rte_time(it,it+5);
	sleep=(175-it[0])%100;
	rte_sleep(sleep);
        nsem_take("fsctl",0);
        if(get_fila10gtime(centisec,it,ip,1,iDBBC)!=0) {
	  endwin();
	  fprintf(stderr,"Field System not running - fmset aborting\n");
	  exit(0);
	}
        nsem_put("fsctl");
	if( ip[2] != 0 )
		{
                logita(NULL,ip[2],ip+3,ip+4);
		logit(NULL,-9,"fv");
		*formtime=-1;
		return;
		}

	/* time before is more accurate */

	centisec[1]=centisec[0];
	centisec[3]=centisec[2];
	centisec[5]=centisec[4];
	
        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
//        rte_fixt(fstime,&centiavg);
        rte_fixt(&fstime32,&centiavg);
        *fstime=fstime32;
        *fshs=centiavg;

	hsdiff=(centisec[3]-centisec[2])*100+centisec[5]-centisec[4];
	*unixhs=centisec[4]+(hsdiff/2)/100;
	*unixtime=centisec[2];
	if(*unixhs>=100) {
	  *unixtime+=*unixhs/100;
	  *unixhs=*unixhs%100;
	}

//        rte2secs(it,formtime);
        rte2secs(it,&formtime32);
        *formtime=formtime32;
        *formhs=0;
}

