/* rdbe detector queries for fivpt */
/* two routines: rdbcn_d identifies the detector to be sampled */
/* rdbcn_v samples it */
/* call rdbcn_d first to set-up sampling and then rdbcn_v can be */
/* called repititively for samples */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 256

static int irdbe, ifc, ichan;
static char unit_letters[]=" abcdefghijklm";
static char who[]="cn";

void rdbcn_d(device, ierr,ip)
char device[4];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
int ip[5];
{
  char crdbe;

  *ierr=0;

  if(3!=sscanf(device,"%2d%c%1d",&ichan,&crdbe,&ifc)||
     (ichan < 0 || ichan >= MAX_RDBE_CH) ||
     NULL==strchr(unit_letters,crdbe) || 
     (ifc < 0 || ifc >= MAX_RDBE_IF)) {
    *ierr=-1;
    return;
  }
  irdbe = strchr(unit_letters,crdbe)-unit_letters-1;
  if(irdbe < 0 || irdbe >= MAX_RDBE)
    *ierr=-1;

  who[1]=crdbe;
  
  return;
}     
void rdbcn_v(double *dtpi, double *dtpi2, int ip[5], int *icont, int *isamples)
{
  char str[20];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char buf[BUFSIZE];
  int out_recs,out_class;
  char name[6];
  int on[MAX_RDBE_CH],off[MAX_RDBE_CH];
  int ierr,ifcr;

  out_recs=0;
  out_class=0;
  sprintf(str,"dbe_tsys?%d;\n",ifc);
  cls_snd(&out_class, str, strlen(str) , 0, 0);
  out_recs++;

  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  sprintf(name,"rdbc%c",unit_letters[irdbe+1]);
  skd_run(name,'w',ip);
  skd_par(ip);
    
  if(ip[2]<0) {
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    return;
  }
  
  if ((nchars =
       cls_rcv(ip[0],buf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
    ip[2] =  -410;
    memcpy(ip+3,"fp",2);
    return;
  }
  buf[nchars]=0;

  if(0!=rdbe_2_tsysx(buf,&ifcr,ip,on,off,who)) {
    return;
  }
  *dtpi=off[ichan];
  *dtpi2=on[ichan];
   
  *icont=1;  /*always continuous for now */
  *isamples= 10;
  
  //  printf(" tpi %f tpi2 %f irdbe %d ichan %d \n",*dtpi,*dtpi2,irdbe,ichan);

  return;

}
