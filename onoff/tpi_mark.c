#include "../include/params.h"

static char *lvcn[]= { "v1","v2","v3","v4","v5","v6","v7","v8","v9","va", 
	       "vb","vc","vd","ve","vf" };

int tpi_mark(ip,itpis,ierr)
long ip[5];                                     /* ipc array */
int itpis[MAX_DET]; /* detector selection array */
int *ierr;
{
  int iclass, nrec, i;
  short int buf2[80];

      iclass=0;
      nrec=0;
      for(i=0;i<17;i++) {
	if(itpis[i]!=0 &&
	   (i!=15||(i==15&&itpis[14]==0))) {
	  if(i<14) {
	    buf2[0]=-22;
	    memcpy(buf2+1,lvcn[i],2);
	  } else if(i==14 || i==15) {
	    buf2[0]=-21;
	    memcpy(buf2+1,"if",2);
	  } else {
	    buf2[0]=-22;
	    memcpy(buf2+1,"i3",2);
	  }
	  cls_snd(&iclass,buf2,4,0,0); nrec++;
	}
      }
      if(matcn(ip,iclass,nrec,ierr))
	return -1;

      return 0;
}

