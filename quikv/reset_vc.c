/* For mark III/IV ifadjust snap command */
/* reset video converters back to where they were when ifadjust started. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int reset_vc(
char *vc_parms_save[14][10],
int vcnum_l[14],
int vcnum_u[14]
)
{
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  long ip[5];
  long iclass;

  for (i=0;i<14;i++) {
    int j;
    for(j=0;j<14;j++) {
      if(vcnum_l[j]==i||vcnum_u[j]==i) {
	goto get;
      }
    }
    continue;
  get:
    iclass=0;
    nrec=0;
    buff[0]=0;
    memcpy(buff+1,&vc_parms_save[i],10);
    cls_snd(&iclass,buff,12,0,0);nrec++;
    
    ip[0]=iclass;
    ip[1]=nrec;
    
    skd_run("matcn",'w',ip);
    skd_par(ip);
      
    if(ip[2]<0) return ierr;
    cls_clr(ip[0]);
  }

  return ierr;
}
