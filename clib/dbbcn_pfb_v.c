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
/* lba module detector queries for fivpt */
/* two routines: dbbcn_pfb_d identifies the module to be sampled */
/* dbbcn_pfb_v samples it */
/* call dbbcn_pfb_d first to set-up sampling and then dbbcn_pfb_v can be */
/* called repititively for samples */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 200

static char *lwhati[ ]={
  "ifa","ifb","ifc","ifd"};
static char ifds[ ]={"abcd"};

static int det;
static int ifchain;
static struct dbbcifx_cmd savec;

double dbbc_if_power(unsigned counts, int como);

void dbbcn_pfb_d(device, ierr,ip)
char device[4];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
int ip[5];
{
  struct dbbcifx_cmd lclc;
  struct dbbcifx_mon lclm;
  char dev[5];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char buf[BUFSIZE];
  int out_recs, out_class;
  char idevice[4];
  int i,j,k,icore;

  *ierr=0;
  savec.agc=0;
  icore=0;
  for (i=0;i<shm_addr->dbbc_cond_mods;i++)
    for (j=0;j<shm_addr->dbbc_como_cores[i];j++) {
      icore++;
      for(k=1;k<16;k++) {
	snprintf(idevice,4,"%c%02d",ifds[i],k+j*16);
	if(strncmp(idevice,device,3)==0) {
	  ifchain=i+1;
	  det=k+(icore-1)*16;
	  goto found;
	}
      }
      if(strncmp(lwhati[i],device,3)==0) {
	ifchain=i+1;
	det=i+MAX_DBBC_PFB;
	goto found;
      }
    }
  *ierr=-1;
  return;

 found:
  dev[0]=device[0];
  dev[1]=device[1];
  dev[2]=device[2];
  dev[3]=0;

  /* read back current if set-up */

  out_recs=0;
  out_class=0;

  sprintf(buf,"dbbcif%c",ifds[ifchain-1]);
  cls_snd(&out_class, buf, strlen(buf) , 0, 0);
  out_recs++;
  
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("dbbcn",'w',ip);
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
    ip[2] =  -401;
    memcpy(ip+3,"fp",2);
    return;
  }
  buf[nchars]=0;
  if( dbbc_2_dbbcifx(&savec,&lclm,buf) !=0) {
    ip[2] = -402;
    memcpy(ip+3,"fp",2);
    return;
  }

  if(savec.agc!=0) {
    out_recs=0;
    out_class=0;
    if(savec.agc!=0) {
      savec.target_null=1;
      memcpy(&lclc,&savec,sizeof(lclc));
      lclc.agc=0;
      lclc.att=-1;
      dbbcifx_2_dbbc(buf,ifchain,&lclc);
      cls_snd(&out_class, buf, strlen(buf) , 0, 0);
      out_recs++;
    }

    ip[0]=1;
    ip[1]=out_class;
    ip[2]=out_recs;
    skd_run("dbbcn",'w',ip);
    skd_par(ip);
    
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
  }
  return;
}     

/* get dataset device voltage request */

void dbbcn_pfb_v(dtpi,ip)
double *dtpi;                      /* return counts */
int ip[5];
{
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char buf[BUFSIZE];
  int out_recs, out_class;
  int ierr;

  out_recs=0;
  out_class=0;

  if(det<MAX_DBBC_PFB) {
    sprintf(buf,"power=%d",1+det/16);
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;
  } else {
    sprintf(buf,"dbbcif%c",ifds[ifchain-1]);
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;
  }
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("dbbcn",'w',ip);
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
    ierr =  -403;
    goto error;
  }
  buf[nchars]=0;
  if(det<MAX_DBBC_PFB) {
    int overflow, k;
    char *sptr;
    double dvalue;
    int ivalue;

    overflow=NULL!=strstr(buf,"OVERFLOW"); /* overflowed */
    sptr=strtok(buf,"=");
    if(NULL==sptr) {
      ierr=-406;
      goto error;
    }
    
    if(shm_addr->dbbcpfbv<=15) {

	/* 'power/ 1=     0.504,     6.255,    31.249,    57.892,    83.805,    87.756,    27.523,     0.434,     2.872,    15.428,    37.493,    57.326,    68.687,    27.936,     0.129' optionally with ' OVERFLOW' at end */

      for(k=1;k<16;k++) {
	sptr=strtok(NULL," ,");
	if(NULL==sptr || 1!=sscanf(sptr,"%lf",&dvalue)) {
	  ierr=-406;
	  goto error;
	}
	if(k==det%16) {
	  if(overflow) {
	    *dtpi=1600001;
	  } else
	    *dtpi=dvalue*1000+.5;
	}
      }
    } else {
      sptr=strtok(NULL," ;");
      for(k=1;k<16;k++) {
	sptr=strtok(NULL," ;");
	if(NULL==sptr || 1!=sscanf(sptr,"%d",&ivalue)) {
	  ierr=-406;
	  goto error;
	}
	if(k==det%16) {
	  if(overflow) {
	    *dtpi=1600001;
	  } else
	    *dtpi=ivalue*10;
	}
      }
    }
  } else {
    struct dbbcifx_cmd lclc;
    struct dbbcifx_mon lclm;

    if( dbbc_2_dbbcifx(&lclc,&lclm,buf) !=0) {
      ierr=-405;
      goto error;
      return;
    }
    *dtpi=dbbc_if_power(lclm.tp, det-MAX_DBBC_PFB);
  }

    return;
 error:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"fp",2);
    return;

}

/* restore if gain */

void dbbcn_pfb_r(ip)
int ip[5];
{
    if(savec.agc!=0) {
      int out_recs, out_class;
      char buf[BUFSIZE];
      out_recs=0;
      out_class=0;
      if(savec.agc!=0 ) {
	savec.att=-1;
	dbbcifx_2_dbbc(buf,ifchain,&savec);
	cls_snd(&out_class, buf, strlen(buf) , 0, 0);
	out_recs++;
      }
    
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      if(ip[0]!=0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
      }
    }
    return;
}
