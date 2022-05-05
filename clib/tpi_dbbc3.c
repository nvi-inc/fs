/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* tpi support utilities for DBBC3 rack */
/* tpi_dbbc3 formats the buffers and runs mcbcn to get data */
/* tpput_dbbc3 stores the result in fscom and formats the output */
/* tsys_dbbc3 does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 512

static char ch[ ]={"abcdefgh"};
static char *lwhat[ ]={
"001l", "002l", "003l", "004l", "005l", "006l", "007l", "008l",
"009l", "010l", "011l", "012l", "013l", "014l", "015l", "016l",
"017l", "018l", "019l", "020l", "021l", "022l", "023l", "024l",
"025l", "026l", "027l", "028l", "029l", "030l", "031l", "032l",
"033l", "034l", "035l", "036l", "037l", "038l", "039l", "040l",
"041l", "042l", "043l", "044l", "045l", "046l", "047l", "048l",
"049l", "050l", "051l", "052l", "053l", "054l", "055l", "056l",
"057l", "058l", "059l", "060l", "061l", "062l", "063l", "064l",
"065l", "066l", "067l", "068l", "069l", "070l", "071l", "072l",
"073l", "074l", "075l", "076l", "077l", "078l", "079l", "080l",
"081l", "082l", "083l", "084l", "085l", "086l", "087l", "088l",
"089l", "090l", "091l", "092l", "093l", "094l", "095l", "096l",
"097l", "098l", "099l", "100l", "101l", "102l", "103l", "104l",
"105l", "106l", "107l", "108l", "109l", "110l", "111l", "112l",
"113l", "114l", "115l", "116l", "117l", "118l", "119l", "120l",
"121l", "122l", "123l", "124l", "125l", "126l", "127l", "128l",
"001u", "002u", "003u", "004u", "005u", "006u", "007u", "008u",
"009u", "010u", "011u", "012u", "013u", "014u", "015u", "016u",
"017u", "018u", "019u", "020u", "021u", "022u", "023u", "024u",
"025u", "026u", "027u", "028u", "029u", "030u", "031u", "032u",
"033u", "034u", "035u", "036u", "037u", "038u", "039u", "040u",
"041u", "042u", "043u", "044u", "045u", "046u", "047u", "048u",
"049u", "050u", "051u", "052u", "053u", "054u", "055u", "056u",
"057u", "058u", "059u", "060u", "061u", "062u", "063u", "064u",
"065u", "066u", "067u", "068u", "069u", "070u", "071u", "072u",
"073u", "074u", "075u", "076u", "077u", "078u", "079u", "080u",
"081u", "082u", "083u", "084u", "085u", "086u", "087u", "088u",
"089u", "090u", "091u", "092u", "093u", "094u", "095u", "096u",
"097u", "098u", "099u", "100u", "101u", "102u", "103u", "104u",
"105u", "106u", "107u", "108u", "109u", "110u", "111u", "112u",
"113u", "114u", "115u", "116u", "117u", "118u", "119u", "120u",
"121u", "122u", "123u", "124u", "125u", "126u", "127u", "128u",
"ia", "ib", "ic", "id", "ie", "if", "ig", "ih"
};

void tpi_dbbc3(ip,itpis_dbbc3)                    /* sample tpi(s) */
int ip[5];                                     /* ipc array */
int itpis_dbbc3[MAX_DBBC3_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc16, U: bbc1...bbc16(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
{
  char outbuf[BUFSIZE];

    int i;
    int out_recs, out_class;

    out_recs=0;
    out_class=0;

    for (i=0;i<MAX_DBBC3_BBC;i++) {
      if(1==itpis_dbbc3[i] || 1==itpis_dbbc3[i+MAX_DBBC3_BBC]) { /* bbc(s) */
	  sprintf(outbuf,"dbbc%03d",1+i%MAX_DBBC3_BBC);    /* '01'-'16' */
	  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	  out_recs++;
      }
    }
    for (i=2*MAX_DBBC3_BBC;i<MAX_DBBC3_DET;i++) {
      if(1==itpis_dbbc3[i]) {                                 /* ifd(s): */
	  sprintf(outbuf,"dbbctp%c",ch[i-2*MAX_DBBC3_BBC]);   /* 'a' - 'd' */
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
    
void tpput_dbbc3(ip,itpis_dbbc3,isubin,ibuf,nch,ilen) /* put results of tpi */
int ip[5];                                    /* ipc array */
int itpis_dbbc3[MAX_DBBC3_DET]; /* device selection array, see tpi_dbbc3 for details */
int isubin;              /* which task: 3=tpi, 4=tpical, 7=tpzero. 11=tpcont  */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    int *ptr,*ptr2;
    int i,j,iclass,nrec,lenstart,isub;
    int tpigainlocal[MAX_DBBC3_DET];
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

    for (i=0;i<MAX_DBBC3_BBC;i++) {
      if(1==itpis_dbbc3[i] || 1==itpis_dbbc3[i+MAX_DBBC3_BBC]) { /* bbc(s) */
	struct dbbc3_bbcnn_cmd lclc;
	struct dbbc3_bbcnn_mon lclm;
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
	if( dbbc3_2_bbcnn(&lclc,&lclm,inbuf) ==0) {
	  tpon[1]=lclm.tpon[1];
	  tpon[0]=lclm.tpon[0];
	  tpoff[1]=lclm.tpoff[1];
	  tpoff[0]=lclm.tpoff[0];
	  //	  if(isub==4) {
	  // tpon[1]+=100;
	  //  tpon[0]+=100;
	  // }
	}
	if(1==itpis_dbbc3[i]) {
	  ptr[i]=tpon[1];
	  if(isub==11)
	    ptr2[i]=tpoff[1];
	}
	if(1==itpis_dbbc3[i+MAX_DBBC3_BBC]) {
	  ptr[i+MAX_DBBC3_BBC]=tpon[0];
	  if(isub==11)
	    ptr2[i+MAX_DBBC3_BBC]=tpoff[0];
	}
      }
    }
    for (i=2*MAX_DBBC3_BBC;i<MAX_DBBC3_DET;i++) {
      if(1==itpis_dbbc3[i]) {                                 /* ifd(s): */
	struct dbbc3_iftpx_mon lclm;
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
	if( dbbc3_2_iftpx(&lclm,inbuf) !=0)
	  ptr[i]=-1;
	else {
	  // if(isub==4) {
	  //  lclm.tp+=10000;
	  // }
	  if(isub==11) {
	    ptr2[i]=lclm.off;
	    ptr[i]=lclm.on;
	  } else
	    ptr[i]=lclm.tp;
	}
      }
    }

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
    lenstart=strlen(ibuf);
    iclass=0;
    nrec=0;
    for(j=-1;j<MAX_DBBC3_IF;j++) {
      int k;
      for(k=0;k<MAX_DBBC3_BBC*2;k++) {
	i=MAX_DBBC3_BBC*(k%2)+k/2;
	if(itpis_dbbc3[ i] == 1 && shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source==j) {
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
	i=2*MAX_DBBC3_BBC+j;
	if(itpis_dbbc3[i]!=0) {
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

void tsys_dbbc3(ip,itpis_dbbc3,ibuf,nch,itask)
int ip[5];                                    /* ipc array */
int itpis_dbbc3[MAX_DBBC3_DET]; /* device selection array, see tpi_dbbc3 for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int itask;               /* 5=tsys, 6=tpidiff, 10=caltemps */
{
  int i,j, inext,iclass,nrec, lenstart;
  double tpi,tpic,tpiz,tpid;

  for (i=0;i<MAX_DBBC3_DET;i++) {
    if(itpis_dbbc3[ i] == 1) {
      if(itask==5) {
	int kskip;
	kskip=i<2*MAX_DBBC3_BBC&&
	  (shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source<0||
	   shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source>(MAX_DBBC3_IF-1));
	tpi=shm_addr->tpi[ i];             /* various pieces */
	tpic=shm_addr->tpical[ i];
	tpiz=0;                            /* digital detector assume tpiz=0 */
	tpid=shm_addr->tpidiff[ i];

	if(kskip)         /* avoid overflow | div-by-0 */
	  shm_addr->systmp[ i]=-1.0;
	else if(tpic<0.5 || tpic > 65534.5 || tpi > 65534.5 || tpi < 0.5 ||
		tpiz < -1 || tpid >999999)
	  shm_addr->systmp[ i]=1e9;
	else {
	  shm_addr->systmp[ i]=(tpi-tpiz)*
	    shm_addr->caltemps[ i]/tpid;
	}
	if(shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0)
	  logita(NULL,-211,"qk",lwhat[i]);
      } else if(itask==6) {
	shm_addr->tpidiff[i]=shm_addr->tpical[i]-shm_addr->tpi[i];
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
  for(j=-1;j<MAX_DBBC3_IF;j++) {
    int k;
    for(k=0;k<MAX_DBBC3_BBC*2;k++) {
      if(k%2==0)
	i=k/2;
      else
	i=MAX_DBBC3_BBC+k/2;
      if(itpis_dbbc3[ i] == 1 && shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source==j) {
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
      i=2*MAX_DBBC3_BBC+j;
      if(itpis_dbbc3[i]!=0) {
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
void cont_dbbc3(itpis_dbbc3,dbbc3_tpi,dbbc3_tpical,samples,isubin,disp)
int itpis_dbbc3[MAX_DBBC3_DET]; /* device selection array, see tpi_dbbc3 for details */
double dbbc3_tpi[2*MAX_DBBC3_BBC];
double dbbc3_tpical[2*MAX_DBBC3_BBC];
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

  for (i=0;i<MAX_DBBC3_DET;i++) {
    if(itpis_dbbc3[ i] == 1) {
      switch (isub) {
      case 3:
	if(dbbc3_tpi[i] >=0.)
	  dbbc3_tpi[i]/=samples;
	break;
      case 4:
	if(dbbc3_tpical[i] >=0.)
	  dbbc3_tpical[i]/=samples;
	break;
      case 10:
	epoch=-1.0;
	get_tcal_fwhm(lwhat[i],&shm_addr->caltemps[i],&fwhm,
		      epoch,&dum, &dum,&dum,&ierr);
	if(ierr!=0) 
	  shm_addr->caltemps[i]=-1.0;
	break;
      case 5:
	kskip=i<2*MAX_DBBC3_BBC&&
	  (shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source<0||
	   shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source>(MAX_DBBC3_IF-1)||
	   shm_addr->caltemps[i]<0.0);
	tpi=dbbc3_tpi[ i];             /* various pieces */
	tpic=dbbc3_tpical[ i];
	tpiz=0;                     /* digital detector assume tpiz=0 */
	if(kskip)         /* avoid overflow | div-by-0 */
	  shm_addr->systmp[ i]=-1.0;
	else if(tpic<0.5 || tpic > 65534.5 || tpi > 65534.5 || tpi < 0.5 ||
		tpiz < -1 )
	  shm_addr->systmp[ i]=1e9;
	else {
	  shm_addr->systmp[ i]=(tpi-tpiz)*
	    shm_addr->caltemps[ i]/(tpic-tpi);
	}
	if(disp &&
	   (shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0))
	  logita(NULL,-211,"qk",lwhat[i]);
      }
    }
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

  for(j=-1;j<MAX_DBBC3_IF;j++) {
    int k;
    for(k=0;k<MAX_DBBC3_BBC*2;k++) {
      if(k%2==0)
	i=k/2;
      else
	i=MAX_DBBC3_BBC+k/2;
      if(itpis_dbbc3[ i] == 1 && shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source==j) {
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
	  flt2str(ibuf,dbbc3_tpi[ i],7,1);
	  break;
	case 4:
	  flt2str(ibuf,dbbc3_tpical[ i],7,1);
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
    if(j!=-1) {
      i=2*MAX_DBBC3_BBC+j;
      if(itpis_dbbc3[i]!=0) {
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
	switch (isub) {
	case 3:
	  flt2str(ibuf,dbbc3_tpi[ i],7,1);
	  break;
	case 4:
	  flt2str(ibuf,dbbc3_tpical[ i],7,1);
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
