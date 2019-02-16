/* get time information from dbbcn */

#include <memory.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/req_ds.h"
#include "../include/res_ds.h"

#define BUFSIZE 2048

int daymy();

get_fila10gtime(centisec,fm_tim,ip,to,iDBBC)
int centisec[6];
int fm_tim[6];
int ip[5];                          /* ipc array */
int to;
int iDBBC;
{
      int out_recs, nrecs, irec, ierr;
      int out_class, iclass;
      char *str;
      char inbuf[BUFSIZE];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      double secs;
      int month,day;

      out_recs=0;
      out_class=0;

      str="fila10g=time";
      cls_snd(&out_class, str, strlen(str) , 0, 0);
      out_recs++;

      ip[0]=4;
      ip[1]=out_class;
      ip[2]=out_recs;

#ifdef DEBUG
      printf("get_fila10gtime ip[0] %d ip[1] %d ip[2] %d\n",ip[0],ip[1],ip[2]);
#endif
      if(to!=0) {
	char *name;
	if(2!=iDBBC)
	  name="dbbcn";
	else
	  name="dbbc2";
	while(skd_run_to(name,'w',ip,120)==1) {
	  if (nsem_test("fs   ") != 1) {
	    return 1;
	  }
	  name=NULL;
	}
      }	else
	skd_run("dbbcn",'w',ip);
      skd_par(ip);

#ifdef DEBUG
      printf("get_fila10gtime ierr %d\n",ip[2]);
#endif

      if(ip[2] <0) {  /* my caller does not clear class records */
	if(ip[1]!=0) 
	  cls_clr(ip[0]);
	return 0;
      }

      iclass=ip[0];
      nrecs=ip[1];
#ifdef DEBUG
      printf(" get_fila10gtime: iclass %d nrecs %d\n",iclass,nrecs);
#endif
      for (irec=0;irec<nrecs;irec++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -401;
	  goto error2;
	}
#ifdef DEBUG
	printf(" get_fila10gtime: irec %d inbuf '%s'\n",irec,inbuf);
#endif
	if(irec==0) {
#ifdef DEBUG
	printf(" get_fila10gtime: irec 0\n");
#endif
	if(6!=sscanf(inbuf,"fila10g/time\n\r%d-%d-%dT%d:%d:%d",
		       fm_tim+5,&month,&day,
			 fm_tim+3,fm_tim+2,fm_tim+1)) {
	    ierr =-402;
	    goto error2;
	  }
	  fm_tim[0]=0;
	  fm_tim[4]=daymy(fm_tim[5],month,day);
#ifdef DEBUG
      printf(" get_filagtime: fm_time decode %d %d %d %d %d %d\n",
	     fm_tim[5],fm_tim[4],fm_tim[3],fm_tim[2],fm_tim[1],fm_tim[0]);
#endif
	} else if (irec==1) {
	  memcpy(centisec,inbuf,24);
#ifdef DEBUG
	  printf(" get_fila10gtime: centisecs %d %d %d %d %d %d\n",
		 centisec[0],centisec[1],centisec[2],centisec[3],centisec[4],
		 centisec[5]);
#endif

	}
      }
       return 0;

error2:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"10",2);
error:
      if(nrecs>irec+1)
	cls_clr(iclass);
      return 0;

}
