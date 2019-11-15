/* get4time.c - get mk4 formatter time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>
#include <string.h>

#include "fmset.h"

extern int ip[5];
extern char inbuf[512];
extern int outclass;
extern int inclass;
extern int rtn1, rtn2, msgflg, save, synch;

void cls_clr();
int cls_rcv();
void cls_snd();
void skd_run();
void skd_par();
void rte2secs();
/*static short tmget[]= {0,'fm','/t','im'};*/
static short tmget[4]= {0,0,0,0};
static short sync_buf[4]= {0,0,0,0};

void get4time(unixtime,unixhs,fstime,fshs,formtime,formhs,raw)
time_t *unixtime; /* computer time */
int *unixhs;
time_t *fstime; /* fs time */
int *fshs;
time_t *formtime; /* formatter time */
int *formhs;
int *raw;
{
	int it[6],ms,nbytes,nrecs,ierr;
        int centisec[6], centiavg, centidiff;
	char *name;
	char buff[80];
	int isynch;
        int formtime32;
        int fstime32;

	if (tmget[0] == 0) {
		tmget[0]=-54;
		memcpy(tmget+1,"fm",2);
		memcpy(tmget+2,"/tim",4);
		sync_buf[0]=11;
		memcpy(sync_buf+1,"fm",2);
		memcpy(sync_buf+2,"/syn",4);
	}
	outclass = 0;
        nrecs=0;
	if(synch) {
	  cls_snd(&outclass, sync_buf ,sizeof(sync_buf), 0, 0); 
	  nrecs++;
	  logit("Formatter sync command sent.",0,NULL);
	}
	cls_snd(&outclass, tmget ,sizeof(tmget), 0, 0); 
	nrecs++;

	ip[0] = outclass; /* class number */
	ip[1] = nrecs;
	ip[2] = 0;
	ip[3] = 0;
	ip[4] = 0;
	name="matcn";
        nsem_take("fsctl",0);
	while(skd_run_to(name,'w',ip,100)==1) {
	  if (nsem_test(NSEM_NAME) != 1) {
	    endwin();
	    fprintf(stderr,"Field System not running - fmset aborting\n");
	    rte_sleep(SLEEP_TIME);
	    exit(0);
	  }
	  name=NULL;
	}
        nsem_put("fsctl");

/* get reply from matcn */
	skd_par(ip);
	inclass = ip[0];
        nrecs = ip[1];
        ierr= ip[2];
	if( ierr < 0 ){
	  logita(NULL,ip[2],ip+3,ip+4);
	  logit(NULL,-10,"fv");
	  *formtime=-1;
	  *raw=0;
	  if(nrecs > 0)
	    cls_clr(inclass);
	  synch=0;
	  return;
	}
	msgflg = save = 0;
	isynch=0;
	if(synch) {
	  synch=0;
	  isynch=1;
	  if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
				 &rtn1, &rtn2, msgflg, save)) <0) {
	    logit(NULL,-6,"fv");
	    *formtime=-1;
	    *raw=0;
	    if(nrecs > 1) 
	      cls_clr(inclass);
	    return;
	  }
	}
	if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                               &rtn1, &rtn2, msgflg, save)) <0) {
	  logit(NULL,-1,"fv");
	  *formtime=-1;
	  *raw=0;
	  if(nrecs > 1+isynch) 
	    cls_clr(inclass);
	  return;
	}
	inbuf[nbytes]='\0';

	if ( (nbytes = cls_rcv(inclass, centisec, 24, 
                               &rtn1, &rtn2, msgflg, save)) <0) {
	  logit(NULL,-2,"fv");
	  *formtime=-1;
	  *raw=0;
	  if(nrecs > 2+isynch) 
	    cls_clr(inclass);
	  return;
	}

	sscanf(inbuf+2,"%d %d %d:%d:%d.%d",it+5,it+4,it+3,it+2,it+1,&ms);
        it[0]=ms/10;
//        rte2secs(it,formtime);
        rte2secs(it,&formtime32);
        *formtime=formtime32;
        *formhs = (ms+5)/10;
	if(*formhs>99) {
	  *formhs-=100;
	  formtime++;
	}

	if(nrecs > 2+isynch) 
	  cls_clr(inclass);  /* clear class numbers just in case */

        if(*formtime<0) {
	  logit(NULL,-3,"fv");
	  *formtime=-1;
	  *raw=0;
	  return;
	} 
	/* for mark IV, first sample closest to truth, but preserve averaging
           logic */

	centisec[1]=centisec[0];
	*unixtime=centisec[2];
	*unixhs=centisec[4];
	
        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
	*raw=centiavg;

//        rte_fixt(fstime,&centiavg);
        rte_fixt(&fstime32,&centiavg);
        *fstime=fstime32;
        *fshs=centiavg;
        
}
