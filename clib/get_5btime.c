/* get time setting information from mk5cn */

#include <memory.h>

#define BUFSIZE 2048


#include "../include/params.h"
#include "../include/fs_types.h"

get_5btime(centisec,fm_tim,ip,to,m5sync,sz_m5sync,m5pps,sz_m5pps,
	   m5freq,sz_m5freq,m5clock,sz_m5clock)
long centisec[6];
int fm_tim[6];
long ip[5];                          /* ipc array */
int to;
char *m5sync;
int sz_m5sync;
char *m5pps;
int sz_m5pps;
char *m5freq;
int sz_m5freq;
char *m5clock;
int sz_m5clock;
{
      int out_recs, nrecs, i, ierr;
      long out_class, iclass;
      char *str;
      struct pps_source_cmd pps_lclc;
      struct clock_set_cmd clock_lclc;
      struct dot_mon lclm;
      char inbuf[BUFSIZE];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      double secs;

      /* get 1pps_source? and clock_set? */

      out_recs=0;
      out_class=0;
      str="1pps_source?\n";
      cls_snd(&out_class, str, strlen(str) , 0, 0);
      out_recs++;

      str="clock_set?\n";
      cls_snd(&out_class, str, strlen(str) , 0, 0);
      out_recs++;

      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;

#ifdef DEBUG
      printf("get_5btime ip[0] %d ip[1] %d ip[2] %d\n",ip[0],ip[1],ip[2]);
#endif
      if(to!=0) {
	char *name;
	name="mk5cn";
	while(skd_run_to(name,'w',ip,120)==1) {
	  if (nsem_test("fs   ") != 1) {
	    return 1;
	  }
	  name=NULL;
	}
      }	else
	skd_run("mk5cn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return 0;

      iclass=ip[0];
      nrecs=ip[1];
#ifdef DEBUG
      printf(" get_5btime: iclass %d nrecs %d\n",iclass,nrecs);
#endif

      for (i=0;i<nrecs;i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -403;
	  goto error2;
	}
#ifdef DEBUG
	printf(" get_5btime: i %d nchars %d\n",i,nchars);
#endif
	if(i==0) {
	  if(0!=m5_2_pps_source(inbuf,&pps_lclc,ip)) {
	    goto error;
	  }
	} else if (i==1) {
	  if(0!=m5_2_clock_set(inbuf,&clock_lclc,ip)) {
	    goto error;
	  }
	}
      }


      /* get dot? */

      out_recs=0;
      out_class=0;
      str="dot?\n";
      cls_snd(&out_class, str, strlen(str) , 0, 0);
      out_recs++;

      ip[0]=4;
      ip[1]=out_class;
      ip[2]=out_recs;

#ifdef DEBUG
      printf("get_5btime ip[0] %d ip[1] %d ip[2] %d\n",ip[0],ip[1],ip[2]);
#endif
      if(to!=0) {
	char *name;
	name="mk5cn";
	while(skd_run_to(name,'w',ip,120)==1) {
	  if (nsem_test("fs   ") != 1) {
	    return 1;
	  }
	  name=NULL;
	}
      }	else
	skd_run("mk5cn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return 0;

#ifdef DEBUG
      printf("get_5btime ierr %d\n",ip[2]);
#endif
      if(ip[2] <0) return 0;

      iclass=ip[0];
      nrecs=ip[1];
#ifdef DEBUG
      printf(" get_5btime: iclass %d nrecs %d\n",iclass,nrecs);
#endif
      for (i=0;i<nrecs;i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -401;
	  goto error2;
	}
#ifdef DEBUG
	printf(" get_5btime: i %d nchars %d\n",i,nchars);
#endif
	if(i==0) {
	  if(0!=m5_2_dot(inbuf,&lclm,ip)) {
	    goto error;
	  }
	} else if (i==1) {
	  memcpy(centisec,inbuf,24);
#ifdef DEBUG
	  printf(" get_5btime: centisecs %d %d %d %d %d %d\n",
		 centisec[0],centisec[1],centisec[2],centisec[3],centisec[4],
		 centisec[5]);
#endif

	}
      }
#ifdef DEBUG
      printf(" get_5btime: decode %s\n",lclm.time.time);
#endif

      if(5!=sscanf(lclm.time.time,"%dy%dd%dh%dm%lfs",fm_tim+5,fm_tim+4,
		   fm_tim+3,fm_tim+2,&secs)) {
	ierr =-402;
	goto error2;
      }
#ifdef DEBUG
      printf(" get_5btime: fm_tim[5] %d fm_tim[4] %d fm_tim[3] %d fm_tim[2] %d secs %lf\n",fm_tim[5],fm_tim[4],fm_tim[3],fm_tim[2],secs);
#endif
      if(secs<59.995) {
	secs+=0.005;
	fm_tim[1]= secs;
	fm_tim[0]= (secs-fm_tim[1])*100;
      } else { /*overflow, increment minutes */
	fm_tim[0]=0;
	fm_tim[1]=0;
	fm_tim[2]+=1;
	if(fm_tim[2] == 60) { /* increment hours */
	  fm_tim[2]=0;
	  fm_tim[3]+=1;
	  if(fm_tim[3] == 24) { /* days */
	    fm_tim[3]=0;
	    fm_tim[4]+=1;
	    if(fm_tim[4] == 367 ||
	       (fm_tim[4]== 366 &&
		!((fm_tim[5] %4 == 0 && fm_tim[5] % 100 != 0)||
		  fm_tim[5] %400 == 0))) { /* years */
	      fm_tim[4]=1;
	      fm_tim[5]+=1;
	    }
	  }
	}
      }
#ifdef DEBUG
      printf(" get_5btime: fm_tim[5] %d fm_tim[4] %d fm_tim[3] %d fm_tim[2] %d fm_tim[1] %d fm_tim[0] %d\n",fm_tim[5],fm_tim[4],fm_tim[3],fm_tim[2],fm_tim[1],fm_tim[0]);
#endif
      if(!lclm.status.state.known) 
	strncpy(lclm.status.status,"sync unknown",sizeof(lclm.status.status));
      strncpy(m5sync,lclm.status.status,sz_m5sync);
      m5sync[sz_m5sync-1]=0;

      if(!pps_lclc.source.state.known) 
	strncpy(pps_lclc.source.source,"unknown",
		sizeof(pps_lclc.source.source));
      strncpy(m5pps,pps_lclc.source.source,sz_m5pps);
      m5pps[sz_m5pps-1]=0;

      if(!clock_lclc.source.state.known) 
	strncpy(clock_lclc.source.source,"unknown",
		sizeof(clock_lclc.source.source));
      strncpy(m5clock,clock_lclc.source.source,sz_m5clock);
      m5clock[sz_m5clock-1]=0;

      if(strcmp(m5clock,"ext")==0) {
	if(!clock_lclc.freq.state.known) {
	  strncpy(m5clock,"unknown",sz_m5clock);
	  m5freq[sz_m5freq-1]=0;
	} else {
	  m5freq[0]=0;
	  int2str(m5freq,clock_lclc.freq.freq,sz_m5freq,0);
	}
      } else if(strcmp(m5clock,"int")==0) {
	if(!clock_lclc.clock_gen.state.known) {
	  strncpy(m5clock,"unknown",sz_m5clock);
	  m5freq[sz_m5freq-1]=0;
	} else {
	  snprintf(m5freq,sz_m5freq,"%lf",clock_lclc.clock_gen.clock_gen);
	  m5freq[sz_m5freq-1]=0;
	}
      } else {
	strncpy(m5clock,"unknown",sz_m5clock);
	m5freq[sz_m5freq-1]=0;
      } 
      return 0;

error2:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"55",2);
error:
      cls_clr(iclass);
      return 0;
}
