/* For mark III/IV ifadjust snap command */
/* attenuation setting function. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int set_att(
int ifone,
int iftwo,
int ifthree,
int patched_ifs[],
int iat[],
char isave[],
char *isave3
)
{
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j;
  long ip[5];
  long iclass;

  /* okay get the IF attenuation */
  if(patched_ifs[0]>0 || patched_ifs[1]>0) {
    iclass=0;
    nrec=0;
    buff[0]=0;
    memcpy(buff+1,"if",2);
    memcpy(buff+2,isave,4);
    sprintf(((char *)buff)+8,"%02x%02x",iftwo,ifone);
    cls_snd(&iclass,buff,12,0,0);nrec++;
  }
  /* okay get the IF3 attenuator setting */
  if(patched_ifs[2]>0){
    buff[0]=0;
    memcpy(buff+1,"i300000",7);
    iat[3]|=ifthree;
    sprintf(((char *)buff)+9,"%c%02x",*isave3,iat[3]);
    iat[3]&=0xc0;
    cls_snd(&iclass,buff,12,0,0);nrec++;
  } 
    ip[0]=iclass;
    ip[1]=nrec;
    
    skd_run("matcn",'w',ip);
    skd_par(ip);

    if(ip[2]<0) return ierr;
    cls_clr(ip[0]);

    return ierr;
}
