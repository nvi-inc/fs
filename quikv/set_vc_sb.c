/* For mark III/IV ifadjust snap command */
/* set upper or lower sideband */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int set_vc_sb(
int *vcnum, 
char which,
int iuse[],
char *vc_parms_save[14][10]
) {
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  int nchar,idum;
  char lvcn[] = {"v1v2v3v4v5v6v7v8v9vavbvcvdve"};
  int ip[5];
  int iclass;


  for (i=0;(*vcnum != -1) && i<14;i++) {
    if(iuse[*vcnum]) {
      iclass=0;
      nrec=0;
      buff[0]=0;
      /* memcpy(buff+1,&vc_parms_save[vcnum[i]],10);*/
      memcpy(buff+1,&vc_parms_save[*vcnum++],10);
      if(which=='l') memcpy(buff+2,"1",1);
      else memcpy(buff+2,"2",1);
      cls_snd(&iclass,buff,12,0,0);nrec++;
      
      ip[0]=iclass;
      ip[1]=nrec;
      
      skd_run("matcn",'w',ip);
      skd_par(ip);
      
      if(ip[2]<0) return ierr;
      cls_clr(ip[0]);
    }
  }
  return ierr;
}

