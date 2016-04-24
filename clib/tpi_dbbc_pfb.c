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
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el","fl","gl",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu","fu","gu",
"ia","ib","ic","id"};
static char *lwhatn[ ]={
  "00","01","02","03","04","05","06","07","08","09","10","11","12","13",
  "14","15"};
static char *lwhati[ ] ={
  "ifa","ifb","ifc","ifd"};
static char *lwhatf[ ] ={
  "fa","fb","fc","fd"};
void tpi_dbbc_pfb(ip,itpis_dbbc_pfb)                    /* sample tpi(s) */
long ip[5];                                     /* ipc array */
int itpis_dbbc_pfb[MAX_DBBC_PFB_DET]; /* detector selection array */
                      /* in order: core 1: channels 0-16
                                   core 2: channels 0-16,
                                      etc to number of availabe Cores   */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
{
  char outbuf[BUFSIZE];

  int i, j, k;
  int out_recs, out_class;
  int icore;

  out_recs=0;
  out_class=0;
  
  icore=0;
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      int found=0;

      icore++;
      for(k=1;k<16 && !(found=itpis_dbbc_pfb[k+(icore-1)*16]);k++)
	;
	if(found) {
	  sprintf(outbuf,"power=%02d",icore);    /* '01'-'04' */
	  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	  out_recs++;
	}
    }
  }
  
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    if(1==itpis_dbbc_pfb[i+MAX_DBBC_PFB]) {        /* ifd(s): */
      sprintf(outbuf,"dbbcif%c",ch[i]);   /* 'a' - 'd' */
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;
    }
  }

  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("dbbcn",'w',ip);
  skd_par(ip);
  
  return;
}
    
void tpput_dbbc_pfb(ip,itpis_dbbc_pfb,isubin,ibuf,nch,ilen) /* put results of tpi */
long ip[5];                                    /* ipc array */
int itpis_dbbc_pfb[MAX_DBBC_PFB_DET]; /* device selection array, see tpi_dbbc_PFB for details */
int isubin;              /* which task: 3=tpi, 4=tpical, 7=tpzero. 11=tpcont  */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
  long *ptr,*ptr2;
  int i,j,k,iclass,nrec,lenstart,isub;
  long tpigainlocal[MAX_DBBC_DET];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE], *sptr;
  int icore, ik;
  int overflow;
  float value;

  isub=abs(isubin);

  switch (isub) {                        /* set the pointer for the type */
  case 3: ptr=shm_addr->tpi; break;
  case 4: ptr=shm_addr->tpical; break;
  case 11: ptr=shm_addr->tpical; ptr2=shm_addr->tpi; break;
  default: ptr=tpigainlocal; break;  /* just being defensive */
  };

  /* retrieve device responses */

  icore=0;
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {

    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      int found=0;

      icore++;
      for(k=1;k<16 && !(found=itpis_dbbc_pfb[k+(icore-1)*16]);k++)
	;
      if(found) {
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(i<ip[1]-1) 
	    cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	  ip[2]=-401;
	  memcpy(ip+3,"qk",2);
	  return;
	}
	inbuf[nchars]=0;

	/* 'power/ 1=     0.504,     6.255,    31.249,    57.892,    83.805,    87.756,    27.523,     0.434,     2.872,    15.428,    37.493,    57.326,    68.687,    27.936,     0.129' optionally with ' OVERFLOW' at end */

	overflow=NULL!=strstr(inbuf,"OVERFLOW"); /* overflowed */
	sptr=strtok(inbuf,"=");
	if(NULL==sptr) {
	  if(i<ip[1]-1) 
	    cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	  ip[2]=-402;
	  memcpy(ip+3,"qk",2);
	  return;
	}

	for(k=1;k<16;k++) {
	  ik=k+(icore-1)*16;
	  sptr=strtok(NULL," ,");
	  if(NULL==sptr || 1!=sscanf(sptr,"%f",&value)) {
	    if(i<ip[1]-1) 
	      cls_clr(ip[0]);
	    ip[0]=ip[1]=0;
	    ip[2]=-402;
	    memcpy(ip+3,"qk",2);
	    return;
	  }
	  if(itpis_dbbc_pfb[ik]) {
	    if(overflow) {
	      ptr[ik]=1600001;
	    } else
	      ptr[ik]=value*1000+.5;
	  }
	}
      }
    }
  }
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    if(1==itpis_dbbc_pfb[i+MAX_DBBC_PFB]) {        /* ifd(s): */
      struct dbbcifx_cmd lclc;
      struct dbbcifx_mon lclm;
      
      if ((nchars =
	   cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	if(i<ip[1]-1) 
	  cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	ip[2]=-401;
	memcpy(ip+3,"qk",2);
	return;
      }
      inbuf[nchars]=0;
      
      if( dbbc_2_dbbcifx(&lclc,&lclm,inbuf) !=0) {
	if(i<ip[1]-1) 
	  cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	ip[2]=-402;
	memcpy(ip+3,"qk",2);
	return;
      } else { 
	if(isub==11) /*actually there is no continuous cal for IFs */
	  ptr2[i+MAX_DBBC_PFB]=lclm.tp;
	else
	  ptr[i+MAX_DBBC_PFB]=lclm.tp;
      }
    }
  }

  /* format log records */

  ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
  lenstart=strlen(ibuf);
  iclass=0;
  nrec=0;

  icore=0;
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      icore++;
      for(k=1;k<16;k++) {
	ik=k+(icore-1)*16;
	if(1==itpis_dbbc_pfb[ik]) {
	  if(strlen(ibuf)>70) {
	    if(isubin > 0) {
	      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	      nrec=nrec+1;
	    } else {
	      ibuf[strlen(ibuf)-1]=0;
	      logit(ibuf,0,NULL);
	    }
	    ibuf[lenstart]=0;
	  }
	  snprintf(ibuf+strlen(ibuf),4,"%c%02d",ch[i],k+j*16);
	  strcat(ibuf,",");
	  if(ptr[ik] >1600000) {
	    strcat(ibuf,"$$$$$,");
	  } else {
	    int2str(ibuf,ptr[ik],7);
	    strcat(ibuf,",");
	  }
	  if(isub==11)
	    if(ptr2[ik] >1600000) {
	      strcat(ibuf,"$$$$$,");
	    } else {
	      int2str(ibuf,ptr2[ik],7);
	      strcat(ibuf,",");
	    }
	}
      }
    }
    if(itpis_dbbc_pfb[i+MAX_DBBC_PFB]!=0) {
      if(strlen(ibuf)>70) {
	if(isubin > 0) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	} else {
	  ibuf[strlen(ibuf)-1]=0;
	  logit(ibuf,0,NULL);
	}
	ibuf[lenstart]=0;
      }
      snprintf(ibuf+strlen(ibuf),4,"if%c",ch[i]);
      strcat(ibuf,",");
      if(isub==11) {
	if(ptr2[i+MAX_DBBC_PFB] > 65534 ) {
	  strcat(ibuf,"$$$$$,");
	} else {
	  flt2str(ibuf,dbbc_if_power(ptr2[i+MAX_DBBC_PFB], i),8,2);
	  strcat(ibuf,",");
	}
      } else {
	if(ptr[i+MAX_DBBC_PFB] > 65534 ) {
	  strcat(ibuf,"$$$$$,");
	} else {
	  flt2str(ibuf,dbbc_if_power(ptr[i+MAX_DBBC_PFB], i),8,2);
	  strcat(ibuf,",");
	}
      }
    }
    if(ibuf[lenstart]!=0) {
      if(isubin > 0) {
	cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	nrec=nrec+1;
      } else {
	ibuf[strlen(ibuf)-1]=0;
	logit(ibuf,0,NULL);
      }
      ibuf[lenstart]=0;
    }
  }
    
  ip[0]=iclass;
  ip[1]=nrec;
  ip[2]=0;
  return;
}

void tsys_dbbc_pfb(ip,itpis_dbbc_pfb,ibuf,nch,itask)
long ip[5];                                    /* ipc array */
int itpis_dbbc_pfb[MAX_DBBC_PFB_DET]; /* device selection array, see tpi_dbbc for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int itask;               /* 5=tsys, 6=tpidiff, 10=caltemps */
{
  int i,j, inext,iclass,nrec, lenstart;
  double tpi,tpic,tpiz,tpid;
  int ik, icore, k;

  icore=0;
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      
      icore++;
      for(k=1;k<16;k++) {
	ik=k+(icore-1)*16;
	if(1==itpis_dbbc_pfb[ik]) {
	  tpi=shm_addr->tpi[ik];             /* various pieces */
	  tpic=shm_addr->tpical[ik];
	  tpiz=0;                        /* digital detector assume tpiz=0 */
	  tpid=shm_addr->tpidiff[ik];
	  if(itask==5) {
	    
	    if(tpic<0.5 || tpic > 1599999.5 || tpi > 1599999.5|| tpi < 0.5|
	       tpiz < -1 || tpid > 1600000.5 )
	      shm_addr->systmp[ik]=1e9;
	    else
	      shm_addr->systmp[ik]=(tpi-tpiz)*
		shm_addr->caltemps[ik]/tpid;

	    if(shm_addr->systmp[ik]>999999.95 || shm_addr->systmp[ik] <0.0)
	      logita(NULL,-215-i,"qk",lwhatn[k]);
	  } else if(itask==6) {
	    if(tpic< 0.5 || tpic>1599999.5|| tpi < 0.5 || tpi > 1599999.5)
	      shm_addr->tpidiff[ik]=1600001;
	    else
	      shm_addr->tpidiff[ik]=shm_addr->tpical[ik]-shm_addr->tpi[ik];
	  } else if(itask==10) {
	    int ierr;
	    float fwhm, epoch, dum;
	    char lwhat3[3];
	    memcpy(lwhat3,ch+i,1);
	    memcpy(lwhat3+1,lwhatn[k],2);
	    epoch=-1.0;
	    get_tcal_fwhm(lwhat3,&shm_addr->caltemps[ik],&fwhm,
			  epoch,&dum, &dum,&dum,&ierr);
	    if(ierr!=0) {
	      ip[0]=ip[1]=0;
	      ip[2]=ierr;
	      return;
	    }
	  }
	}
      }
    }
    ik=i+MAX_DBBC_PFB;
    if(1==itpis_dbbc_pfb[ik]) {        /* ifd(s): */
      tpi=shm_addr->tpi[ik];             /* various pieces */
      tpic=shm_addr->tpical[ik];
      tpiz=0;                        /* digital detector assume tpiz=0 */
      tpid=shm_addr->tpidiff[ik];
      if(itask==5) {
	if(tpic<0.5 || tpic > 65534.5 || tpi > 65534.5 || tpi < 0.5 ||
		tpiz < -1 || tpid >999999)
	  shm_addr->systmp[ik]=1e9;
	else
	  shm_addr->systmp[ik]=(dbbc_if_power(shm_addr->tpi[ik], i)-tpiz)*
	    shm_addr->caltemps[ik]/
	    (dbbc_if_power(shm_addr->tpical[ik],i)-
	     dbbc_if_power(shm_addr->tpi[ik],i));
	if(shm_addr->systmp[ik]>999999.95 || shm_addr->systmp[ik] <0.0)
	  logita(NULL,-219,"qk",lwhatf[i]);
      } else if(itask==6) {
	if(tpic<0.5 || tpic > 65534.5 || tpi > 65534.5 || tpi < 0.5)
	  shm_addr->tpidiff[ik]=100000;
	else
	  shm_addr->tpidiff[ik]=0.5+
	    dbbc_if_power(shm_addr->tpical[ik],i)-
	    dbbc_if_power(shm_addr->tpi[ik],i);
      } else if(itask==10) {
	int ierr;
	float fwhm, epoch, dum;
	epoch=-1.0;
	get_tcal_fwhm(lwhati[i],&shm_addr->caltemps[ik],&fwhm,
		      epoch,&dum, &dum,&dum,&ierr);
	if(ierr!=0) {
	  ip[0]=ip[1]=0;
	  ip[2]=ierr;
	  return;
	}
      }
    }	
  }

  ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
  lenstart=strlen(ibuf);
  iclass=0;
  nrec=0;

  icore=0;
  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      
      icore++;
      for(k=1;k<16;k++) {
	ik=k+(icore-1)*16;
	if(1==itpis_dbbc_pfb[ik]) {
	  if(strlen(ibuf)>70) {
	    cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	    nrec=nrec+1;
	    ibuf[lenstart]=0;
	  }
	  snprintf(ibuf+strlen(ibuf),4,"%c%02d",ch[i],k+j*16);
	  strcat(ibuf,",");
	  if(itask==5) 
	    flt2str(ibuf,shm_addr->systmp[ik],8,1);
	  else if(itask==6) {
	    int2str(ibuf,shm_addr->tpidiff[ik],5);
	  } else if(itask==10) 
	    flt2str(ibuf,shm_addr->caltemps[ik],8,3);
	  
	  strcat(ibuf,",");
	}
      }
    }
    ik=i+MAX_DBBC_PFB;
    if(1==itpis_dbbc_pfb[ik]) {        /* ifd(s): */
      if(strlen(ibuf)>70) {
	cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	nrec=nrec+1;
	ibuf[lenstart]=0;
      }
      strcat(ibuf,lwhati[i]);
      strcat(ibuf,",");
      if(itask==5) 
	flt2str(ibuf,shm_addr->systmp[ik],8,1);
      else if(itask==6) {
	if(shm_addr->tpidiff[ik] > 99999)
	  int2str(ibuf,shm_addr->tpidiff[ik],5);
	else
	  flt2str(ibuf,
		  dbbc_if_power(shm_addr->tpical[ik],i)-
		  dbbc_if_power(shm_addr->tpi[ik],i),
		  8,2);
      } else if(itask==10) 
	flt2str(ibuf,shm_addr->caltemps[ik],8,3);
      strcat(ibuf,",");
    }
    if(ibuf[lenstart]!=0) {
      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
      nrec=nrec+1;
      ibuf[lenstart]=0;
    }
  }

  ip[0]=iclass;
  ip[1]=nrec;
  ip[2]=0;
  return;

}
