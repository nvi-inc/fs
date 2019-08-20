#include <string.h>

setMK4FMrec(val,ip)
int val;
int ip[5];
{

  short int buff[80];
  int iclass, nrec;

  iclass=0;
  nrec=0;

  buff[0]=9;
  memcpy(buff+1,"fm",2);
  buff[2]=0;

  if(val == 1)
    strcpy((char *) (buff+2),"/rec 1");
  else
    strcpy((char *) (buff+2),"/rec 0");
  cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
  
  ip[0]=iclass;
  ip[1]=nrec;
  skd_run("matcn",'w',ip);
  skd_par(ip);
  if(ip[2] < 0) return;
  cls_clr(ip[0]);
}

