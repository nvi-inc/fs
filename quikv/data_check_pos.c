#include <stdio.h>
#include <string.h>

#include "../include/m5state_ds.h"
#include "../include/disk_pos_ds.h"

#define BUFSIZE 512

int data_check_pos(ip)
long ip[5];
{

  long out_class;
  int out_recs, ierr, icount;
  double pos;
  char outbuf[BUFSIZE];
  char inbuf[BUFSIZE];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char *ptr;
  struct disk_pos_mon lclm;
  long class, nrecs;
  int i;

  out_recs=0;
  out_class=0;
  
  strcpy(outbuf,"position?\n");
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
    return -1;
  }

  class=ip[0];
  nrecs=ip[1];

  for (i=0;i<nrecs;i++) {
    char *ptr;
    if ((nchars =
	 cls_rcv(class,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
      ip[3] = -401;
      goto error;
    }
    if(i==0)
      if(0!=m5_2_disk_pos(inbuf,&lclm,ip)) {
	cls_clr(class);
	return -1;
      }
  }

  pos=lclm.record.record-1e6;

  if(pos<0) {
    ierr=-402;
    goto error;
  }

  out_recs=0;
  out_class=0;
    
  sprintf(outbuf,"play = off : %16.0lf\n",pos);
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
    return -1;
  }

  cls_clr(ip[0]);
  ip[0]=ip[1]=0;
  ip[0]=ip[1]=ip[2]=0;
  return 0;

  error:
    cls_clr(ip[0]);
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"5d",2);
    return -1;
}
