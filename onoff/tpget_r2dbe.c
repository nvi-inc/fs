/* tpget_r2dbe formats the buffers and runs rbdn to get data */
/* tpput_r2dbe stores the result in fscom and formats the output */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 2048

static char unit_letters[ ] = {" abcdefghijklm"}; /* mk6/rdbe unit letters */
    
int tpget_r2dbe(cont,ip,itpis_r2dbe,ierr,dtpi,dtpi2) /* put results of tpi & tpi2 */
int cont[MAX_R2DBE_DET];                          /* non-zero is continuous */
long ip[5];                                    /* ipc array */
int itpis_r2dbe[MAX_R2DBE_DET]; /* device selection array, see tpi_dbbc for details */
int *ierr;
double dtpi[MAX_R2DBE_DET],dtpi2[MAX_R2DBE_DET];
{
  int i, j, k, ind, irdbe, ichan, ifc;
  int ifs[MAX_RDBE][MAX_R2DBE_IF];
  char str[256];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars, iwhich;
  char inbuf[BUFSIZE];
  int out_recs[MAX_RDBE],out_class[MAX_RDBE];
  char name[6], who[3];
  long iplast[5];
  long on[MAX_R2DBE_CH],off[MAX_R2DBE_CH];

  for(i=0;i<MAX_RDBE;i++)
    for(j=0;j<MAX_R2DBE_IF;j++)
      ifs[i][j]=0;

  for (i=0;i<MAX_R2DBE_DET;i++)
    if(1==itpis_r2dbe[i])
      ifs[i/(MAX_R2DBE_IF*MAX_R2DBE_CH)]
	[(i%(MAX_R2DBE_IF*MAX_R2DBE_CH))/MAX_R2DBE_CH]=1;
  
  for (i=0;i<MAX_RDBE;i++) {
    out_class[i]=0;
    out_recs[i]=0;
    for(j=0;j<MAX_R2DBE_IF;j++)
      if(ifs[i][j]) {
	sprintf(inbuf,"dbe_tsys?%d;\n",j);
	cls_snd(&out_class[i], inbuf, strlen(inbuf) , 0, 0);
	out_recs[i]++;
      }
    if(out_recs[i]!=0) {
      ip[0]=1;
      ip[1]=out_class[i];
      ip[2]=out_recs[i];
      sprintf(name,"rdbc%c",unit_letters[i+1]);
      iwhich=i+1;
      skd_run_p(name,'p',ip,&iwhich); /* from here until the last
					 skd_run_p(NULL,'w',...) is
					 processed, we have to handle
					 errors locally, no passing up
					   i.e. too hard to unwind */
    }
  }
  
  for(j=0;j<5;j++)
    iplast[j]=0;

  for (i=0;i<MAX_RDBE;i++) 
    if(out_recs[i]!=0) {   /* we aren't using "i" as index, iwhich will be */
      skd_run_p(NULL,'w',ip,&iwhich);
      skd_par(ip);
      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
      } else {
	strcpy(who,"cx");
	who[1]=unit_letters[iwhich];
	for(j=0;j<ip[1];j++) {
	  if ((nchars =
	       cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	    if(j<ip[1]-1) 
	      cls_clr(ip[0]);
	    ip[2]= -115;	  
	    memcpy(ip+3,"nf",2);
	    memcpy(ip+4,who,2);
	    goto error;
	  }
	  inbuf[nchars]=0;
	  if(0!=r2dbe_2_tsysx(inbuf,&ifc,ip,on,off,who)) {
	    logita(NULL,ip[2],ip+3,ip+4);
	    if(j<ip[1]-1) 
	      cls_clr(ip[0]);
	    ip[2]= -116;	  
	    memcpy(ip+3,"nf",2);
	    memcpy(ip+4,who,2);
	    goto error;
	  }
	  if(ifc <0 || ifc >=MAX_R2DBE_IF ||
	     ifs[iwhich-1][ifc]==0) {
	    if(j<ip[1]-1) 
	      cls_clr(ip[0]);
	    ip[2]= -117;	  
	    memcpy(ip+3,"nf",2);
	    memcpy(ip+4,who,2);
	    goto error;
	  }
	  for(k=0;k<MAX_R2DBE_CH;k++) {
	    ind=k+(iwhich-1)*MAX_R2DBE_CH*MAX_R2DBE_IF+ifc*MAX_R2DBE_CH;
	    if(1==itpis_r2dbe[ind]) {
	      dtpi2[ind]=on[k];
	      dtpi[ind]=off[k];
	    }
	  }
	}
      }
    error:
      if(ip[2]!=0 && iplast[2]!=0) {
	logita(NULL,iplast[2],iplast+3,iplast+4);
      }
      if(ip[2]!=0) {
	for(j=2;j<5;j++)
	  iplast[j]=ip[j];
      }
    }

  /* local error processing no longer require */
  if(iplast[2]!=0)
    for(j=2;j<5;j++)
      ip[j]=iplast[j];
  
  ip[0]=0;
  ip[1]=0;
  *ierr=ip[2];

  if(ip[2]<0)
    return -1;
  else
    return 0;

}
