/* tpi support utilities for DBBC_PFB rack */
/* tpi_dbbc_pfb formats the buffers and runs mcbcn to get data */
/* tpput_dbbc_pfb stores the result in fscom and formats the output */
/* tsys_dbbc_pfb does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 512

double dbbc_if_power(unsigned counts, int como);

static char ch[ ]={"abcd"};

int tpget_dbbc_pfb(ip,itpis_dbbc_pfb,dtpi,ierr) /* put results of tpi */
int ip[5];                                    /* ipc array */
int itpis_dbbc_pfb[MAX_DBBC_PFB_DET]; /* device selection array, see tpi_dbbc_PFB for details */
double dtpi[MAX_DBBC_PFB_DET];
int *ierr;
{
  int i,j,k;
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE], *sptr;
  int icore;
  int overflow;
  double dvalue;
  int ivalue;

  /* retrieve device responses */

  icore=0;
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {

    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      int found=0;

      icore++;
      for(k=1;k<16 && !(found=itpis_dbbc_pfb[k+(icore-1)*16]);k++)
	;
      if(found) {
	ip[1]--;
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(ip[1]>0) 
	    cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	  *ierr=-17;
	  return -1;
	}
	inbuf[nchars]=0;

	overflow=NULL!=strstr(inbuf,"OVERFLOW"); /* overflowed */
	sptr=strtok(inbuf,"=");
	if(NULL==sptr) {
	  if(ip[1]>0) 
	    cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	  *ierr=-18;
	  return -1;
	}

	if(shm_addr->dbbcpfbv<=15) {
	/* 'power/ 1=     0.504,     6.255,    31.249,    57.892,    83.805,    87.756,    27.523,     0.434,     2.872,    15.428,    37.493,    57.326,    68.687,    27.936,     0.129' optionally with ' OVERFLOW' at end */

	  for(k=1;k<16;k++) {
	    sptr=strtok(NULL," ,");
	    if(NULL==sptr || 1!=sscanf(sptr,"%lf",&dvalue)) {
	      if(ip[1]>0) 
		cls_clr(ip[0]);
	      ip[0]=ip[1]=0;
	      *ierr=-18;
	      return -1;
	    }
	    if(itpis_dbbc_pfb[k+(icore-1)*16]) {
	      if(overflow) {
		dtpi[k+(icore-1)*16]=1600001;
	      } else
		dtpi[k+(icore-1)*16]=dvalue;
	    }
	  }
	} else {
	  /* 'power/ 1= 26888;   671;  1198;  1939;  2708;  3710;  3652;  3697;  5286;  6315;  5763;  5688;  7497;  6597;  6395;  3507' optionally with ' OVERFLOW' at end, first value is not a channel */
	  sptr=strtok(NULL," ;");
	  for(k=1;k<16;k++) {
	    sptr=strtok(NULL," ;");
	    if(NULL==sptr || 1!=sscanf(sptr,"%d",&ivalue)) {
	      if(ip[1]>0) 
		cls_clr(ip[0]);
	      ip[0]=ip[1]=0;
	      *ierr=-18;
	      return -1;
	    }
	    if(itpis_dbbc_pfb[k+(icore-1)*16]) {
	      if(overflow) {
		dtpi[k+(icore-1)*16]=1600001;
	      } else
		dtpi[k+(icore-1)*16]=ivalue*10;
	    }
	  }
	}
      }
    }
  }
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    if(1==itpis_dbbc_pfb[i+MAX_DBBC_PFB]) {        /* ifd(s): */
      struct dbbcifx_cmd lclc;
      struct dbbcifx_mon lclm;
      
      ip[1]--;
      if ((nchars =
	   cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	if(ip[1]>0) 
	  cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	*ierr=-17;
	return -1;
      }
      inbuf[nchars]=0;
      
      if( dbbc_2_dbbcifx(&lclc,&lclm,inbuf) !=0) {
	if(ip[1]>0) 
	  cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	*ierr=-18;
	return -1;
      } else { 
	  dtpi[i+MAX_DBBC_PFB]=dbbc_if_power(lclm.tp,i);
      }
    }
  }
  return 0;
}
