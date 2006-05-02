#include <stdio.h>
#include <string.h>

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
  long class, nrecs;
  int i;

  out_recs=0;
  out_class=0;
    
  strcpy(outbuf,"scan_set = : -1000000 ;\n");
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
