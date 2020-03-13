/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* get5btime.c - get vlba formatter time */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <memory.h>      /* for memcpy */
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>

#include "../include/params.h"

#include "fmset.h"

extern int ip[5];           /* parameters for fs communications */
extern int synch;
extern int rack, rack_type;
extern int m5b_crate;
extern int dbbcddcv;

extern dbbc_sync;
extern WINDOW	* maindisp;  /* main display WINDOW data structure pointer */

void rte2secs();

void get5btime(unixtime,unixhs,fstime,fshs,formtime,formhs,raw,
	       m5sync,sz_m5sync,m5pps,sz_m5pps,m5freq,sz_m5freq,m5clock,
	       sz_m5clock,ierr)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
int *raw;
char *m5sync;
int sz_m5sync;
char *m5pps;
int sz_m5pps;
char *m5freq;
int sz_m5freq;
char *m5clock;
int sz_m5clock;
int *ierr;
{
	int centisec[6], centiavg, centidiff, hsdiff;
        int it[6];
	char *name;
	char *str;
	int out_recs;
	int out_class;
	char buff[80];
        int formtime32;
  int fstime32;

	if(synch) {
	  int i, iwait;

	  iwait=0;
	  synch=0;
	  mvwaddstr( maindisp, 4, 6+15,
		     "                                       ");
	  mvwaddstr( maindisp, 4, 6+15+39 , "               ");
	  mvwaddstr( maindisp, 5, 6+15,
		     "                                       ");
	  mvwaddstr( maindisp, 5, 6+15+39 , "               ");
	  mvwaddstr( maindisp, 6, 6+15,
		     "                                       ");
	  mvwaddstr( maindisp, 6, 6+15+39 , "               ");

	  if(rack == DBBC &&
             (rack_type == DBBC_DDC || rack_type == DBBC_DDC_FILA10G) &&
             dbbcddcv>=107) {  // could be a 5B feed through a FiLa10G
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
	      *raw=0;
	      return;
	    }
	    rte_sleep(150); 
	  }

	  if(rack == DBBC && dbbc_sync) {
      /* we can't get here for source==DBBC unless rack == DBBC &&
       * drive==MK5B, i.e., source is irrelevant */
	    dbbc_sync=0;
	    out_recs=0;
	    out_class=0;

	    str="pps_sync";
	    cls_snd(&out_class, str, strlen(str) , 0, 0);
	    out_recs++;
	    logit("DBBC sync command sent.",0,NULL);

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
	      *raw=0;
	      return;
	    }
	    wstandout(maindisp);
	    mvwaddstr( maindisp, 4, 21, "Waiting for DBBC ");
	    leaveok ( maindisp, FALSE); /* leave cursor in place */
	    wrefresh ( maindisp );
	    for(i=0;i<2;i++) {  /*wait for 2nd next 1 PPS before continuing */
	      rte_sleep(100); 
	      mvwaddstr( maindisp, 4,21+17+i, ".");
	      leaveok ( maindisp, FALSE); /* leave cursor in place */
	      wrefresh ( maindisp );
	    }
	    rte_sleep(26);
	    mvwaddstr( maindisp, 4,21+17+i, " ");
	    iwait=1;

	    /* send a harmless monitor command so pps_sync is not
	       the last thing in DBBC input buffer */

	    out_recs=0;
	    out_class=0;

	    str="dbbcifa";
	    cls_snd(&out_class, str, strlen(str) , 0, 0);
	    out_recs++;

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
	      *raw=0;
	      return;
	    }

	  }
	  out_recs=0;
	  out_class=0;

	  str="1pps_source = vsi;\n";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;
	  logit("Mark 5B 1pps_source command sent.",0,NULL);
	    
	  str="tvr = 0;\n";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;

	  if(m5b_crate > 1 && m5b_crate <= 64) {
	    sprintf(buff,"clock_set = %d : ext;\n",m5b_crate);
	    cls_snd(&out_class, buff, strlen(buff) , 0, 0);
	    out_recs++;
	    sprintf(buff,"Mark 5B clock_set (%d MHz) command sent.",m5b_crate);
	    logit(buff,0,NULL);
	  }
	  str="dot_set= : force;\n";
	  cls_snd(&out_class, str, strlen(str) , 0, 0);
	  out_recs++;
	     
	  logit("Mark 5B sync command sent.",0,NULL);
	  ip[0]=1;
	  ip[1]=out_class;
	  ip[2]=out_recs;
	  
	  nsem_take("fsctl",0);
	  name="mk5cn";
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
	    logit(NULL,-8,"fv");
	    *formtime=-1;
	    *raw=0;
	    return;
	  }
	  wstandout(maindisp);
	  mvwaddstr( maindisp, 4, 21+iwait*20, "Waiting for Mark 5B ");
	  leaveok ( maindisp, FALSE); /* leave cursor in place */
	  wrefresh ( maindisp );
	  for(i=0;i<2;i++) {  /*wait for 2nd next 1 PPS before continuing */
	    rte_sleep(100); 
	    mvwaddstr( maindisp, 4, 21+iwait*20+20+i, ".");
	    leaveok ( maindisp, FALSE); /* leave cursor in place */
	    wrefresh ( maindisp );
	  }
	  wstandend(maindisp);
	  rte_sleep(26); 
	}


        nsem_take("fsctl",0);
        if(get_5btime(centisec,it,ip,1,m5sync,sz_m5sync,m5pps,sz_m5pps,
		      m5freq,sz_m5freq,m5clock,sz_m5clock)!=0) {
	  endwin();
	  fprintf(stderr,"Field System not running - fmset aborting\n");
	  rte_sleep(SLEEP_TIME);
	  exit(0);
	}
        nsem_put("fsctl");
	if( ip[2] != 0 ) {
	  logita(NULL,ip[2],ip+3,ip+4);
	  logit(NULL,-8,"fv");
	  *ierr=ip[2];
	  *formtime=-1;
	  *raw=0;
	  return;
	}

	/* time before is more accurate */
	
	centisec[1]=centisec[0];
	centisec[3]=centisec[2];
	centisec[5]=centisec[4];

        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
	*raw=centiavg;

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
        *formhs=it[0];
}
