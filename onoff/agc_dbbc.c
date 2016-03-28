/* tpi support utilities for VLBA rack */
/* tpi_vlba formats the buffers and runs mcbcn to get data */
/* tpput_vlba stores the result in fscom and formats the output */
/* tsys_vlba does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 100

int agc_dbbc(itpis_dbbc,agcin,ierr)                    /* sample tpi(s) */
int itpis_dbbc[MAX_DBBC_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc16, U: bbc1...bbc16(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int agcin;              /* value to send 0=fixed,1=before fixed */
int *ierr;
{
  static int agc[MAX_DBBC_IF], att[MAX_DBBC_IF], mode[MAX_DBBC_IF];
  int i, ifchain;
  long ip[5];                                     /* ipc array */
  int out_recs, out_class;
  char buf[BUFSIZE];
  static bbcs;

    if(agcin==0) {
      bbcs=0;
      for (i=0;i<MAX_DBBC_IF;i++)
	mode[i]=0;
      
      for (i=0;i<MAX_DBBC_BBC;i++) {
	if(1==itpis_dbbc[i]||1==itpis_dbbc[i+MAX_BBC]) {
	  bbcs=1;
	  ifchain=shm_addr->dbbcnn[i].source+1;
	  if(ifchain <1 || ifchain >4)
	    continue;
	  mode[ifchain-1]=1;
	  agc[ifchain-1]=shm_addr->dbbcifx[ifchain-1].agc;
	  att[ifchain-1]=shm_addr->dbbcifx[ifchain-1].att;
	}
      }

      for (i=0;i<MAX_DBBC_IF;i++) {
	if(!mode[i] && 1==itpis_dbbc[i+2*MAX_DBBC_BBC]) {
	  mode[i]=1;
	  agc[i]=shm_addr->dbbcifx[i].agc;
	  att[i]=shm_addr->dbbcifx[i].att;
	}
      }
    }

    out_recs=0;
    out_class=0;

    for (i=0;i<MAX_DBBC_IF;i++) {
      if(mode[i] && agc[i]!=0) {
	if(agcin==0) {
	  shm_addr->dbbcifx[i].agc=0;
	  shm_addr->dbbcifx[i].att=-1;
	} else {
	  shm_addr->dbbcifx[i].agc=agc[i];
	  shm_addr->dbbcifx[i].att=att[i];
	}
	dbbcifx_2_dbbc(buf,i+1,&shm_addr->dbbcifx[i]);
	cls_snd(&out_class, buf, strlen(buf) , 0, 0);
	out_recs++;
      }
    }
    if(bbcs && shm_addr->dbbcddcv > 102) {
      if(agcin==0)
	strcpy(buf,"dbbcgain=all,man");
      else
	strcpy(buf,"dbbcgain=all,agc");
      cls_snd(&out_class, buf, strlen(buf) , 0, 0);
      out_recs++;
    }
    if(out_recs!=0) {
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);
      
      cls_clr(ip[0]);
      if(ip[2]<0) {
	if(ip[1]!=0)
	  cls_clr(ip[0]);
	logita(NULL,ip[2],ip+3,ip+4);
	*ierr=-10;
	return -1;
      }
    }

    return 0;
}
