/* tpi support utilities for DBBC rack */
/* tpi_dbbc formats the buffers and runs mcbcn to get data */
/* tpput_dbbc stores the result in fscom and formats the output */
/* tsys_dbbc does tsys calculations for tsysX commands */

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

void tpi_dbbc(ip,itpis_dbbc)                    /* sample tpi(s) */
int ip[5];                                     /* ipc array */
int itpis_dbbc[MAX_DBBC_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc16, U: bbc1...bbc16(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
{
  char outbuf[BUFSIZE];

    int i;
    int out_recs, out_class;

    out_recs=0;
    out_class=0;

    for (i=0;i<MAX_DBBC_BBC;i++) {
      if(1==itpis_dbbc[i] || 1==itpis_dbbc[i+MAX_DBBC_BBC]) { /* bbc(s) */
	  sprintf(outbuf,"dbbc%02d",1+i%MAX_DBBC_BBC);    /* '01'-'16' */
	  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	  out_recs++;
      }
    }
    for (i=2*MAX_DBBC_BBC;i<MAX_DBBC_DET;i++) {
      if(1==itpis_dbbc[i]) {                                 /* ifd(s): */
	  sprintf(outbuf,"dbbcif%c",ch[i-2*MAX_DBBC_BBC]);   /* 'a' - 'd' */
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
    
void tpput_dbbc(ip,itpis_dbbc,isubin,ibuf,nch,ilen) /* put results of tpi */
int ip[5];                                    /* ipc array */
int itpis_dbbc[MAX_DBBC_DET]; /* device selection array, see tpi_dbbc for details */
int isubin;              /* which task: 3=tpi, 4=tpical, 7=tpzero. 11=tpcont  */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    int *ptr,*ptr2;
    int i,j,iclass,nrec,lenstart,isub;
    int tpigainlocal[MAX_DBBC_DET];
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    char inbuf[BUFSIZE];

    isub=abs(isubin);

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       case 11: ptr=shm_addr->tpical; ptr2=shm_addr->tpi; break;
       default: ptr=tpigainlocal; break;  /* just being defensive */
    };

    for (i=0;i<MAX_DBBC_BBC;i++) {
      if(1==itpis_dbbc[i] || 1==itpis_dbbc[i+MAX_DBBC_BBC]) { /* bbc(s) */
	struct dbbcnn_cmd lclc;
	struct dbbcnn_mon lclm;
	int tpon[2],tpoff[2];

	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(i<ip[1]-1) 
	    cls_clr(ip[0]);
	  logita(NULL,ip[2],ip+3,ip+4);
	  ip[2]=-401;
	  memcpy(ip+3,"qk",2);
	  return;
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
	  //	  if(isub==4) {
	  // tpon[1]+=100;
	  //  tpon[0]+=100;
	  // }
	}
	if(1==itpis_dbbc[i]) {
	  ptr[i]=tpon[1];
	  if(isub==11)
	    ptr2[i]=tpoff[1];
	}
	if(1==itpis_dbbc[i+MAX_DBBC_BBC]) {
	  ptr[i+MAX_DBBC_BBC]=tpon[0];
	  if(isub==11)
	    ptr2[i+MAX_DBBC_BBC]=tpoff[0];
	}
      }
    }
    for (i=2*MAX_DBBC_BBC;i<MAX_DBBC_DET;i++) {
      if(1==itpis_dbbc[i]) {                                 /* ifd(s): */
	struct dbbcifx_cmd lclc;
	struct dbbcifx_mon lclm;

	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(i<ip[1]-1) 
	    cls_clr(ip[0]);
	  logita(NULL,ip[2],ip+3,ip+4);
	  ip[2]=-401;
	  memcpy(ip+3,"qk",2);
	  return;
	}
	inbuf[nchars]=0;

	if( dbbc_2_dbbcifx(&lclc,&lclm,inbuf) !=0)
	  ptr[i]=-1;
	else {
	  // if(isub==4) {
	  //  lclm.tp+=10000;
	  // }
	  if(isub==11)
	    ptr2[i]=lclm.tp;
	  else
	    ptr[i]=lclm.tp;
	}
      }
    }

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
    lenstart=strlen(ibuf);
    iclass=0;
    nrec=0;
    for(j=-1;j<MAX_DBBC_IF;j++) {
      int k;
      for(k=0;k<MAX_DBBC_BBC*2;k++) {
	i=MAX_DBBC_BBC*(k%2)+k/2;
	if(itpis_dbbc[ i] == 1 && shm_addr->dbbcnn[i%MAX_DBBC_BBC].source==j) {
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
	  strcat(ibuf,lwhat[i]);
	  strcat(ibuf,",");
	  if(ptr[i] >65534) {
	    strcat(ibuf,"$$$$$,");
	  } else {
	    int2str(ibuf,ptr[i],5,0);
	    strcat(ibuf,",");
	  }
	  if(isub==11)
	    if(ptr2[i] >65534) {
	      strcat(ibuf,"$$$$$,");
	    } else {
	      int2str(ibuf,ptr2[i],5,0);
	      strcat(ibuf,",");
	    }
	}
      }
      if(j!=-1) {
	i=2*MAX_DBBC_BBC+j;
	if(itpis_dbbc[i]!=0) {
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
	  strcat(ibuf,lwhat[i]);
	  strcat(ibuf,",");
	  if(isub==11) {
	    if(ptr2[i] > 65534 ) {
	      strcat(ibuf,"$$$$$,");
	    } else {
	      flt2str(ibuf,dbbc_if_power(ptr2[i], j),8,2);
	      strcat(ibuf,",");
	    }
	  } else {
	    if(ptr[i] > 65534 ) {
	      strcat(ibuf,"$$$$$,");
	    } else {
	      flt2str(ibuf,dbbc_if_power(ptr[i], j),8,2);
	      strcat(ibuf,",");
	    }
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

void tsys_dbbc(ip,itpis_dbbc,ibuf,nch,itask)
int ip[5];                                    /* ipc array */
int itpis_dbbc[MAX_DBBC_DET]; /* device selection array, see tpi_dbbc for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int itask;               /* 5=tsys, 6=tpidiff, 10=caltemps */
{
  int i,j, inext,iclass,nrec, lenstart;
  double tpi,tpic,tpiz,tpid;

  for (i=0;i<MAX_DBBC_DET;i++) {
    if(itpis_dbbc[ i] == 1) {
      if(itask==5) {
	int kskip;
	kskip=i<2*MAX_DBBC_BBC&&
	  (shm_addr->dbbcnn[i%MAX_DBBC_BBC].source<0||
	   shm_addr->dbbcnn[i%MAX_DBBC_BBC].source>3);
	tpi=shm_addr->tpi[ i];             /* various pieces */
	tpic=shm_addr->tpical[ i];
	tpiz=0;                            /* digital detector assume tpiz=0 */
	tpid=shm_addr->tpidiff[ i];

	if(kskip)         /* avoid overflow | div-by-0 */
	  shm_addr->systmp[ i]=-1.0;
	else if(tpic<0.5 || tpic > 65534.5 || tpi > 65534.5 || tpi < 0.5 ||
		tpiz < -1 || tpid >999999)
	  shm_addr->systmp[ i]=1e9;
	else if(i<2*MAX_DBBC_BBC) {
	  shm_addr->systmp[ i]=(tpi-tpiz)*
	    shm_addr->caltemps[ i]/tpid;
	} else {
	  shm_addr->systmp[ i]=(dbbc_if_power(tpi, i-2*MAX_DBBC_BBC)-tpiz)*
	    shm_addr->caltemps[ i]/
	    (dbbc_if_power(tpic,i-2*MAX_DBBC_BBC)-
	     dbbc_if_power(tpi,i-2*MAX_DBBC_BBC));

	}
	if(shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0)
	  logita(NULL,-211,"qk",lwhat[i]);
      } else if(itask==6) {
	if(i<2*MAX_DBBC_BBC)
	  shm_addr->tpidiff[i]=shm_addr->tpical[i]-shm_addr->tpi[i];
	else {
	  shm_addr->tpidiff[i]=0.5+
	    dbbc_if_power(shm_addr->tpical[i],i-2*MAX_DBBC_BBC)-
	    dbbc_if_power(shm_addr->tpi[i],i-2*MAX_DBBC_BBC);
	  // printf(" i %d tpical %d tpi %d tpid %d\n",
	  // i,shm_addr->tpical[i], shm_addr->tpi[i],
	  // shm_addr->tpidiff[i]);
	}
	if(shm_addr->tpical[i]>65534.5||
	   shm_addr->tpical[i]<0.5||
	   shm_addr->tpi[i]>65534.5||
	   shm_addr->tpi[i]<0.5)
	  shm_addr->tpidiff[i]=100000;
      } else if(itask==10) {
	int ierr;
	float fwhm, epoch, dum;
	epoch=-1.0;
	get_tcal_fwhm(lwhat[i],&shm_addr->caltemps[i],&fwhm,
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
  for(j=-1;j<MAX_DBBC_IF;j++) {
    int k;
    for(k=0;k<MAX_DBBC_BBC*2;k++) {
      if(k%2==0)
	i=k/2;
      else
	i=MAX_DBBC_BBC+k/2;
      if(itpis_dbbc[ i] == 1 && shm_addr->dbbcnn[i%MAX_DBBC_BBC].source==j) {
	if(strlen(ibuf)>70) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	if(itask==5) 
	  flt2str(ibuf,shm_addr->systmp[ i],8,1);
	else if(itask==6) {
	  int2str(ibuf,shm_addr->tpidiff[i],5,0);
	} else if(itask==10) 
	  flt2str(ibuf,shm_addr->caltemps[ i],8,3);

	strcat(ibuf,",");
      }
    }
    if(j!=-1) {
      i=2*MAX_DBBC_BBC+j;
      if(itpis_dbbc[i]!=0) {
	if(strlen(ibuf)>70) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	if(itask==5) 
	  flt2str(ibuf,shm_addr->systmp[ i],8,1);
	else if(itask==6) {
	  if(shm_addr->tpidiff[i] > 99999)
	    int2str(ibuf,shm_addr->tpidiff[i],5,0);
	  else
	    flt2str(ibuf,
		    dbbc_if_power(shm_addr->tpical[i],i-2*MAX_DBBC_BBC)-
		    dbbc_if_power(shm_addr->tpi[i],i-2*MAX_DBBC_BBC),
		    8,2);
	} else if(itask==10) 
	  flt2str(ibuf,shm_addr->caltemps[ i],8,3);
	strcat(ibuf,",");
      }
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
void cont_dbbc(itpis_dbbc,dbbc_tpi,dbbc_tpical,samples,isubin,disp)
int itpis_dbbc[MAX_DBBC_DET]; /* device selection array, see tpi_dbbc for details */
double dbbc_tpi[2*MAX_DBBC_BBC];
double dbbc_tpical[2*MAX_DBBC_BBC];
int samples;
int isubin;   /* which task: 3=tpi, 4=tpical, 5=tsys, 10=caltemps. */
int disp;    /* non-zero means display tsys data as regular user data */
{
  int i,j, k, inext,iclass,nrec, lenstart, kskip;
  double tpi,tpic,tpiz,tpid;
  int ierr;
  float fwhm, epoch, dum;
  char  ibuf[256];        /* out array, formatted results placed here */
  int nch;                /* next available char index in ibuf */
  int isub;

  isub=abs(isubin);

  for (i=0;i<2*MAX_DBBC_BBC;i++) {
    if(itpis_dbbc[ i] == 1) {
      switch (isub) {
      case 3:
	if(dbbc_tpi[i] >=0.)
	  dbbc_tpi[i]/=samples;
	break;
      case 4:
	if(dbbc_tpical[i] >=0.)
	  dbbc_tpical[i]/=samples;
	break;
      case 10:
	epoch=-1.0;
	get_tcal_fwhm(lwhat[i],&shm_addr->caltemps[i],&fwhm,
		      epoch,&dum, &dum,&dum,&ierr);
	if(ierr!=0) 
	  shm_addr->caltemps[i]=-1.0;
	break;
      case 5:
	kskip=i<2*MAX_DBBC_BBC&&
	  (shm_addr->dbbcnn[i%MAX_DBBC_BBC].source<0||
	   shm_addr->dbbcnn[i%MAX_DBBC_BBC].source>3||
	   shm_addr->caltemps[i]<0.0);
	tpi=dbbc_tpi[ i];             /* various pieces */
	tpic=dbbc_tpical[ i];
	tpiz=0;                     /* digital detector assume tpiz=0 */
	if(kskip)         /* avoid overflow | div-by-0 */
	  shm_addr->systmp[ i]=-1.0;
	else if(tpic<0.5 || tpic > 65534.5 || tpi > 65534.5 || tpi < 0.5 ||
		tpiz < -1 )
	  shm_addr->systmp[ i]=1e9;
	else if(i<2*MAX_DBBC_BBC) {
	  shm_addr->systmp[ i]=(tpi-tpiz)*
	    shm_addr->caltemps[ i]/(tpic-tpi);
	}
	if(disp &&
	   (shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0))
	  logita(NULL,-211,"qk",lwhat[i]);
      }
    }
  }

  if(3 == isub)
    for(j=0;j<MAX_DBBC_IF;j++) {
      i=j+2*MAX_DBBC_BBC;
      if(itpis_dbbc[ i] == 1 && dbbc_tpi[i] >=0.)
	dbbc_tpi[i]/=samples;
    }

  if(!disp && 5 != isub)
    return;

  switch (isub) {
  case 3:
    strcpy(ibuf,"tpi/");
    break;
  case 4:
    strcpy(ibuf,"tpical/");
    break;
  case 10:
    strcpy(ibuf,"caltemp/");
    break;
  case 5:
    strcpy(ibuf,"tsys/");
    break;
  }
  lenstart=strlen(ibuf);

  for(j=-1;j<MAX_DBBC_IF;j++) {
    int k;
    for(k=0;k<MAX_DBBC_BBC*2;k++) {
      if(k%2==0)
	i=k/2;
      else
	i=MAX_DBBC_BBC+k/2;
      if(itpis_dbbc[ i] == 1 && shm_addr->dbbcnn[i%MAX_DBBC_BBC].source==j) {
	if(strlen(ibuf)>75) {
	  ibuf[strlen(ibuf)-1]=0;
	  if(disp) 
	    logitf(ibuf);
	  else
	    logit(ibuf,0,NULL);
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	switch (isub) {
	case 3:
	  flt2str(ibuf,dbbc_tpi[ i],7,1);
	  break;
	case 4:
	  flt2str(ibuf,dbbc_tpical[ i],7,1);
	  break;
	case 10:
	  flt2str(ibuf,shm_addr->caltemps[ i],8,3);
	  break;
	case 5:
	  flt2str(ibuf,shm_addr->systmp[ i],8,1);
	  break;
	}
	strcat(ibuf,",");
      }
    }
    if(j!=-1 && isub == 3) {
      i=2*MAX_DBBC_BBC+j;
      if(itpis_dbbc[i]!=0) {
	if(strlen(ibuf)>70) {
	  ibuf[strlen(ibuf)-1]=0;
	  if(disp) 
	    logitf(ibuf);
	  else
	    logit(ibuf,0,NULL);
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	flt2str(ibuf,dbbc_tpi[ i],8,2);
	strcat(ibuf,",");
      }
    }
    if(ibuf[lenstart]!=0) {
      ibuf[strlen(ibuf)-1]=0;
      if(disp) 
	logitf(ibuf);
      else
	logit(ibuf,0,NULL);
      ibuf[lenstart]=0;
    }
  }
  return;

}
