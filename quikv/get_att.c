/* For mark III/IV ifadjust snap command */
/* Get attenution values. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256

int get_att(
int patched_ifs[],
int iat[],
char isave[],
char *isave3
) 
{
  short int buff[MAX_BUF];
  int ierr=0, nrec, i, j, isave2[6];
  int nchar,idum;
  long ip[5];
  long iclass;

  /* okay get the IF attenuation */
  if(patched_ifs[0]>0 || patched_ifs[1]>0) {
    iclass=0;
    nrec=0;
    buff[0]=-2;
    memcpy(buff+1,"if",2);
    cls_snd(&iclass,buff,4,0,0); nrec++;

    ip[0]=iclass;
    ip[1]=nrec;

    skd_run("matcn",'w',ip);
    skd_par(ip);
    
    if(ip[2]<0) return ierr;
    iclass=ip[0];

    nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
    ((char *) buff)[nchar]=0;
    memcpy(isave,((char *) buff)+2,4);
    if(2!=sscanf(((char *)buff)+6,"%2x%2x",&iat[1],&iat[0])) {
      ierr=-502;
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"if",2);
      return ierr;
    }
  }

  /* okay get the IF3 attenuator setting */
  if(patched_ifs[2]>0){
    iclass=0;
    nrec=0;
    buff[0]=-2;
    memcpy(buff+1,"i3",2);
    cls_snd(&iclass,buff,4,0,0); nrec++;
    
    ip[0]=iclass;
    ip[1]=nrec;

    skd_run("matcn",'w',ip);
    skd_par(ip);
    
    if(ip[2]<0) return ierr;
    iclass=ip[0];

    nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
    ((char *) buff)[nchar]=0;
    memcpy(isave2,((char *) buff)+2,6);
    if(1!=sscanf(((char *)buff)+8,"%2x",&iat[2])) {
      ierr=-509;
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"if",2);
      return ierr;
    }
    /* Six (6) bits are used for the attenuators 0-5 */
    /* Adjust appropriately and save bits 6 and 7 */
    iat[3]=iat[2]&0xc0;
    if(iat[3]==0x80) iat[3]=0x0;
    else iat[3]=0x40;
    iat[2]&=0x3f;

  /* Now get the Ext. switch states */
    iclass=0;
    nrec=0;
    buff[0]=-1;
    memcpy(buff+1,"i3",2);
    cls_snd(&iclass,buff,4,0,0); nrec++;

    ip[0]=iclass;
    ip[1]=nrec;

    skd_run("matcn",'w',ip);
    skd_par(ip);

    if(ip[2]<0) return ierr;
    iclass=ip[0];

    nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
    ((char *) buff)[nchar]=0;
    memcpy((char *)isave3,((char *) buff)+9,1);
  }
  return ierr;
}




