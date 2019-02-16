#include <stdio.h>

int matcn(ip,iclass,nrec,ierr)
     int ip[5];
     int iclass, nrec, *ierr;
{
  if(brk_chk("onoff")!=0) {
    *ierr=-1;
    return -1;
  }

  ip[0]=iclass;
  ip[1]=nrec;
  skd_run("matcn",'w',ip);
  skd_par(ip);
  if (ip[2]>=0)
    return 0;
  if(ip[1]!=0) {
    cls_clr(ip[0]);
    ip[0]=ip[1]=0;
  }
  logita(NULL,ip[2],ip+3,ip+4);

  *ierr=-70;
  return -1;
}
