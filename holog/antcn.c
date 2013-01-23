#include <stdio.h>

int antcn(ip1,ierr)
     long ip1;
     int *ierr;
{
  long ip[5] = {0,0,0,0,0};
  int i;

  ip[0]=ip1;

  for(i=0;i<2;i++) {
    if(brk_chk("holog")!=0) {
      *ierr=-1;
      return -1;
    }
    skd_run("antcn",'w',ip);
    if(ip[2]>=0)
      return 0;
    logita(NULL,ip[2],ip+3,ip+4);
  }

  *ierr=-30;
  return -1;
}
