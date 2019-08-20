/* lba module detector queries for fivpt */
/* two routines: dscon_d identifies the module to be sampled */
/* dbbcn_v samples it */
/* call dbbcn_d first to set-up sampling and then dbbcn_v can be */
/* called repititively for samples */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 100

static char bbcs[ ]={"123456789abcdefg"};
static char ifds[ ]={"abcd"};

static int det;
static int ifchain;
static struct dbbcifx_cmd savec;

double dbbc_if_power(unsigned counts, int como);

void dbbcn_d(device, ierr,ip)
char device[2];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
int ip[5];
{
  struct dbbcifx_cmd lclc;
  struct dbbcifx_mon lclm;
  char dev[3];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char buf[BUFSIZE];
  int out_recs, out_class;

  *ierr=0;
  savec.agc=0;

  if ((device[0]!='i' || NULL == strchr(ifds,device[1])) &&
       (NULL== strchr(bbcs,device[0]) ||
	NULL == strchr("ul",device[1]))) {
    *ierr = -1;
    return;
  }
  dev[0]=device[0];
  dev[1]=device[1];
  dev[2]=0;

  if(dev[0]=='i') {
    ifchain=1+(int)(index(ifds,dev[1])-ifds);
    det=2*MAX_DBBC_BBC+ifchain-1;
  } else {
    det=(int)(index(bbcs,dev[0])-bbcs);
    ifchain=shm_addr->dbbcnn[det].source+1;
    if(dev[1]=='u')
      det+=MAX_DBBC_BBC;
  }

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
    if(savec.agc!=0 || (shm_addr->dbbcddcv > 102 && det < 2*MAX_DBBC_BBC)) {
      out_recs=0;
      out_class=0;
      if(savec.agc!=0) {
	savec.target_null=1;
	memcpy(&lclc,&savec,sizeof(lclc));
	lclc.agc=0;
	lclc.att=-1;
	savec.target_null=1;
	dbbcifx_2_dbbc(buf,ifchain,&lclc);
	cls_snd(&out_class, buf, strlen(buf) , 0, 0);
	out_recs++;
      }
      if(shm_addr->dbbcddcv > 102 && det < 2*MAX_DBBC_BBC) {
	strcpy(buf,"dbbcgain=all,man");
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

void dbbcn_v(dtpi,dtpi2,ip,icont,isamples)
double *dtpi,*dtpi2;                      /* return counts */
int ip[5];
int *icont, *isamples;
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

  if(det<2*MAX_DBBC_BBC) {
    *icont=shm_addr->dbbc_cont_cal.mode;
    sprintf(buf,"dbbc%02.2d",1+det%MAX_DBBC_BBC);
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;
  } else {
    *icont=0;
    sprintf(buf,"dbbcif%c",ifds[ifchain-1]);
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;
  }
  *isamples=shm_addr->dbbc_cont_cal.samples;
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
  if(det<2*MAX_DBBC_BBC) {
    struct dbbcnn_cmd lclc;
    struct dbbcnn_mon lclm;

    if( dbbc_2_dbbcnn(&lclc,&lclm,buf) !=0) {
      ierr=-404;
      goto error;
    }
    if(det<MAX_DBBC_BBC) {
      if(0==*icont)
	*dtpi=lclm.tpon[1];
      else {
	*dtpi=lclm.tpoff[1];
	*dtpi2=lclm.tpon[1];
      }
    } else
      if(0==*icont)
	*dtpi=lclm.tpon[0];
      else {
	*dtpi=lclm.tpoff[0];
	*dtpi2=lclm.tpon[0];
      }
  } else {
    struct dbbcifx_cmd lclc;
    struct dbbcifx_mon lclm;

    if( dbbc_2_dbbcifx(&lclc,&lclm,buf) !=0) {
      ierr=-405;
      goto error;
      return;
    }
    *dtpi=dbbc_if_power(lclm.tp, det-2*MAX_DBBC_BBC);
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

void dbbcn_r(ip)
int ip[5];
{
    if(savec.agc!=0 || (shm_addr->dbbcddcv > 102 && det < 2*MAX_DBBC_BBC)) {
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
      if(shm_addr->dbbcddcv > 102 && det < 2*MAX_DBBC_BBC) {
	strcpy(buf,"dbbcgain=all,agc");
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
