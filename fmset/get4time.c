/* get4time.c - get mk4 formatter time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */

#include "fmset.h"

extern long ip[5];
extern char inbuf[512];
extern long outclass;
extern long inclass;
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
long *raw;
{
	int it[6],ms,nbytes,nrecs,ierr;
        long centisec[6], centiavg, centidiff;
	int cnt=0;
	char *name;

	if (tmget[0] == 0) {
		tmget[0]=-54;
		memcpy(tmget+1,"fm",2);
		memcpy(tmget+2,"/tim",4);
		sync_buf[0]=11;
		memcpy(sync_buf+1,"fm",2);
		memcpy(sync_buf+2,"/syn",4);
	}
tryagain:
	outclass = 0;
        nrecs=0;
	if(synch) {
	  cls_snd(&outclass, sync_buf ,sizeof(sync_buf), 0, 0); 
	  nrecs++;
	  logit("Formatter re-synch command sent.",0,NULL);
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
	if( ierr < 0 )
		{
		endwin();
		fprintf(stderr,"Error reply from matcn - error %d\n", ierr );
                logita(NULL,ip[2],ip+3,ip+4);
		cls_clr(outclass);
		cls_clr(inclass);
                rte_sleep(SLEEP_TIME);
		exit(0);
		}
	msgflg = save = 0;
	if(synch) {
	  if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
				 &rtn1, &rtn2, msgflg, save)) <0)
	    {
	      endwin();
	      fprintf(stderr,"Error rec. msg - %d bytes received\n" ,nbytes);
	      logita(NULL,-6,"fv"," ");
	      cls_clr(outclass);
	      cls_clr(inclass);
	      rte_sleep(SLEEP_TIME);
	      exit(0);
	    }
	  synch=0;
	}
	if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                               &rtn1, &rtn2, msgflg, save)) <0)
		{
		endwin();
		fprintf(stderr,"Error rec. msg - %d bytes received\n" ,nbytes);
                logita(NULL,-1,"fv"," ");
		cls_clr(outclass);
		cls_clr(inclass);
                rte_sleep(SLEEP_TIME);
		exit(0);
		}
	inbuf[nbytes]='\0';

	if ( (nbytes = cls_rcv(inclass, centisec, 24, 
                               &rtn1, &rtn2, msgflg, save)) <0)
		{
		endwin();
		fprintf(stderr,
			"Error rec. time - %d bytes received\n" ,nbytes);
                logita(NULL,-2,"fv"," ");
		cls_clr(outclass);
		cls_clr(inclass);
                rte_sleep(SLEEP_TIME);
		exit(0);
		}

	sscanf(inbuf+2,"%d %d %d:%d:%d.%d",it+5,it+4,it+3,it+2,it+1,&ms);
        it[0]=ms/10;
        rte2secs(it,formtime);
        *formhs = (ms+5)/10;
	if(*formhs>99) {
	  *formhs-=100;
	  formtime++;
	}

	cls_clr(outclass); /* clear class numbers just in case */
	cls_clr(inclass);

	  /*
        if(*formtime<0) 
		if(cnt++>5) {
		endwin();
		fprintf(stderr,"Error year less than 1970 for 5 tries\n");
                logita(NULL,-3,"fv"," ");
		cls_clr(outclass);
		cls_clr(inclass);
                rte_sleep(SLEEP_TIME);
		exit(0);
		} else
			goto tryagain;
			*/
	/* for mark IV, first sample closest to truth, but preserve averaging
           logic */

	centisec[1]=centisec[0];
	*unixtime=centisec[2];
	*unixhs=centisec[4];
	
        centidiff =centisec[1]-centisec[0];
        centiavg= centisec[0]+centidiff/2;
	*raw=centiavg;

        rte_fixt(fstime,&centiavg);
        *fshs=centiavg;
        
}
