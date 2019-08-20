/* tpi_dbbc formats the buffers and runs dbbcn to get data */
/* tpput_dbbc stores the result in fscom and formats the output */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

double dbbc_if_power(unsigned counts, int como);

#define BUFSIZE 512
    
int tpget_dbbc(cont,ip,itpis_dbbc,ierr,tpi,tpi2) /* put results of tpi & tpi2 */
int cont[MAX_DBBC_DET];                          /* non-zero is continuous */
int ip[5];                                    /* ipc array */
int itpis_dbbc[MAX_DBBC_DET]; /* device selection array, see tpi_dbbc for details */
int *ierr;
float tpi[MAX_DBBC_DET],tpi2[MAX_DBBC_DET];
{
    int i;
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    char inbuf[BUFSIZE];


    for (i=0;i<MAX_DBBC_BBC;i++) {
      if(1==itpis_dbbc[i] || 1==itpis_dbbc[i+MAX_DBBC_BBC]) { /* bbc(s) */
	struct dbbcnn_cmd lclc;
	struct dbbcnn_mon lclm;
	int tpon[2],tpoff[2];

	ip[1]--;
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(ip[1]>0) 
	    cls_clr(ip[0]);
	  *ierr=-17;
	  return -1;
	}
	inbuf[nchars]=0;

	tpon[1]=-1;
	tpon[0]=-1;
	tpoff[1]=-1;
	tpoff[0]=-1;
	if( dbbc_2_dbbcnn(&lclc,&lclm,inbuf) ==0) {
	  tpon[1]=lclm.tpon[1];
	  tpon[0]=lclm.tpon[0];
	  tpoff[1]=lclm.tpoff[1];
	  tpoff[0]=lclm.tpoff[0];
	} else {
	  if(ip[1]>0) 
	    cls_clr(ip[0]);
	  *ierr=-18;
	  return -1;
	}
	if(1==itpis_dbbc[i]) {
	  if(cont[i]) {
	    tpi[i]=tpoff[1];
	    tpi2[i]=tpon[1];
	  } else
	    tpi[i]=tpon[1];
	}
	if(1==itpis_dbbc[i+MAX_DBBC_BBC])
	  if(cont[i+MAX_DBBC_BBC]) {
	    tpi[i+MAX_DBBC_BBC]=tpoff[0];
	    tpi2[i+MAX_DBBC_BBC]=tpon[0];
	  } else
	    tpi[i+MAX_DBBC_BBC]=tpon[0];
      }
    }
    for (i=2*MAX_DBBC_BBC;i<MAX_DBBC_DET;i++) {
      if(1==itpis_dbbc[i]) {                                 /* ifd(s): */
	struct dbbcifx_cmd lclc;
	struct dbbcifx_mon lclm;

	ip[1]--;
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(ip[1]>0) 
	    cls_clr(ip[0]);
	  *ierr=-19;
	  return -1;
	}
	inbuf[nchars]=0;

	cont[i]=0;
	tpi2[i]=-1;
	if( dbbc_2_dbbcifx(&lclc,&lclm,inbuf) !=0) {
	  if(ip[1]>0) 
	    cls_clr(ip[0]);
	  *ierr=-21;
	  return -1;
	} else
	  tpi[i]=dbbc_if_power(lclm.tp,i-2*MAX_DBBC_BBC);
      }
    }
    return 0;
}
