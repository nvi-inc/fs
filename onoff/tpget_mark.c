#include <stdio.h>
#include "../include/params.h"

#define MAX_BUF 256

void tpget_mark(ip,itpis,tpi)
long ip[5];                                     /* ipc array */
int itpis[MAX_DET]; /* detector selection array */
float tpi[MAX_DET]; /* detector value array */
{
  int nrec, iclass, nr, i, idum, nchar, ierr;
  char buf3[MAX_BUF];

  nrec = ip[1];
  iclass = ip[0];
  nr=0;
  for(i=0;i<17;i++) {
    long ipwr;
    if (itpis[i]==0)
      continue;
    if(i!=15||itpis[14]==0) {
      if(nr>=nrec)
	continue;
      nchar=cls_rcv(iclass,&ierr,MAX_BUF,&idum,&idum,0,0);
      nchar=cls_rcv(iclass,buf3,MAX_BUF,&idum,&idum,0,0);
      nr=nr+2;
    }
    if(ierr>=0 && 1== sscanf(buf3+(i<=14?6:2),"%4x",&ipwr)) {
      if(ipwr>=65535)
	tpi[i+14]=1e9;
      else 
	tpi[i+14]=ipwr;
    } else if(ierr<0)
      tpi[i+14]=ierr;
    else
      tpi[i+14]=-9999;
  }
}
