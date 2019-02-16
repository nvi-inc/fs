/* dbbc3 module detector queries for fivpt */
/* two routines: dscon_d identifies the module to be sampled */
/* dbbc3n_v samples it */
/* call dbbc3n_d first to set-up sampling and then dbbc3n_v can be */
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

static char bbcs[ ]={"0123456789"};
static char ifds[ ]={"abcdefgh"};

static int det;
static int ifchain;
static struct dbbc3_ifx_cmd savec;

void dbbc3n_d(device, ierr,ip)
char device[2];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
int ip[5];
{
  struct dbbc3_ifx_cmd lclc;
  struct dbbc3_ifx_mon lclm;
  char dev[5];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char buf[BUFSIZE];
  int out_recs, out_class;
  int devnm;

  *ierr=0;

  devnm=atoi(device);

  if ((device[0]!='i' || NULL == strchr(ifds,device[1]) || device[2] != ' ' ||
       device[3]!=' ') &&
      (NULL== strchr(bbcs,device[0]) || NULL == strchr(bbcs,device[1]) ||
       NULL== strchr(bbcs,device[2]) || devnm < 1 || devnm >MAX_DBBC3_BBC ||
       NULL == strchr("ul",device[3]))) {
    *ierr = -1;
    return;
  }
  dev[0]=device[0];
  dev[1]=device[1];
  dev[2]=device[2];
  dev[3]=device[3];
  dev[4]=0;

  if(dev[0]=='i') {
    ifchain=1+(int)(index(ifds,dev[1])-ifds);
    det=2*MAX_DBBC3_BBC+ifchain-1;
  } else {
    det=devnm-1;
    ifchain=shm_addr->dbbc3_bbcnn[det].source+1;
    if(dev[3]=='u')
      det+=MAX_DBBC3_BBC;
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
  if( dbbc3_2_ifx(&savec,&lclm,buf) !=0) {
    ip[2] = -402;
    memcpy(ip+3,"fp",2);
    return;
  }
  if(savec.agc!=0 || det < 2*MAX_DBBC3_BBC) {
    out_recs=0;
    out_class=0;
    if(savec.agc!=0) {
      savec.target_null=1;
      memcpy(&lclc,&savec,sizeof(lclc));
      lclc.agc=0;
      lclc.att=-1;
      savec.target_null=1;
      ifx_2_dbbc3(buf,ifchain,&lclc);
      cls_snd(&out_class, buf, strlen(buf) , 0, 0);
      out_recs++;
    }
    if(det < 2*MAX_DBBC3_BBC) {
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

void dbbc3n_v(dtpi,dtpi2,ip,icont,isamples)
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

  *icont=shm_addr->dbbc3_cont_cal.mode;
  if(det<2*MAX_DBBC3_BBC) {
    sprintf(buf,"dbbc%03d",1+det%MAX_DBBC3_BBC);
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;
  } else {
    sprintf(buf,"dbbctp%c",ifds[ifchain-1]);
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;
  }
  *isamples=shm_addr->dbbc_cont_cal.samples;
  ip[0]=8;
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
  if(det<2*MAX_DBBC3_BBC) {
    struct dbbc3_bbcnn_cmd lclc;
    struct dbbc3_bbcnn_mon lclm;

    if( dbbc3_2_bbcnn(&lclc,&lclm,buf) !=0) {
      ierr=-404;
      goto error;
    }
    if(det<MAX_DBBC3_BBC) {
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
    struct dbbc3_iftpx_mon lclm;

    if( dbbc3_2_iftpx(&lclm,buf) !=0) {
      ierr=-405;
      goto error;
      return;
    }
    if(0==*icont)
      *dtpi=lclm.tp;
     else {
      *dtpi=lclm.off;
      *dtpi2=lclm.on;
    }
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

void dbbc3n_r(ip)
int ip[5];
{
  if(savec.agc!=0 || det < 2*MAX_DBBC3_BBC) {
    int out_recs, out_class;
    char buf[BUFSIZE];
    out_recs=0;
    out_class=0;
    if(savec.agc!=0 ) {
      savec.att=-1;
      ifx_2_dbbc3(buf,ifchain,&savec);
      cls_snd(&out_class, buf, strlen(buf) , 0, 0);
      out_recs++;
    }
    if(det < 2*MAX_DBBC3_BBC) {
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
