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

int agc_dbbc3(itpis_dbbc3,agcin,ierr)                    /* sample tpi(s) */
int itpis_dbbc3[MAX_DBBC3_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc16, U: bbc1...bbc16(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int agcin;              /* value to send 0=fixed,1=before fixed */
int *ierr;
{
  static int agc[MAX_DBBC3_IF], att[MAX_DBBC3_IF], mode[MAX_DBBC3_IF];
  int i, ifchain;
  int ip[5];                                     /* ipc array */
  int out_recs, out_class;
  char buf[BUFSIZE];
  static bbcs;

    if(agcin==0) {
      bbcs=0;
      for (i=0;i<MAX_DBBC3_IF;i++)
	mode[i]=0;
      
      for (i=0;i<MAX_DBBC3_BBC;i++) {
	if(1==itpis_dbbc3[i]||1==itpis_dbbc3[i+MAX_DBBC3_BBC]) {
	  bbcs=1;
	  ifchain=shm_addr->dbbc3_bbcnn[i].source+1;
	  if(ifchain <1 || ifchain >MAX_DBBC3_IF)
	    continue;
	  mode[ifchain-1]=1;
	  agc[ifchain-1]=shm_addr->dbbc3_ifx[ifchain-1].agc;
	  att[ifchain-1]=shm_addr->dbbc3_ifx[ifchain-1].att;
	}
      }

      for (i=0;i<MAX_DBBC3_IF;i++) {
	if(!mode[i] && 1==itpis_dbbc3[i+2*MAX_DBBC3_BBC]) {
	  mode[i]=1;
	  agc[i]=shm_addr->dbbc3_ifx[i].agc;
	  att[i]=shm_addr->dbbc3_ifx[i].att;
	}
      }
    }

    out_recs=0;
    out_class=0;

    for (i=0;i<MAX_DBBC3_IF;i++) {
      if(mode[i] && agc[i]!=0) {
	if(agcin==0) {
	  shm_addr->dbbc3_ifx[i].agc=0;
	  shm_addr->dbbc3_ifx[i].att=-1;
	} else {
	  shm_addr->dbbc3_ifx[i].agc=agc[i];
	  shm_addr->dbbc3_ifx[i].att=att[i];
	}
	ifx_2_dbbc3(buf,i+1,&shm_addr->dbbc3_ifx[i]);
	cls_snd(&out_class, buf, strlen(buf) , 0, 0);
	out_recs++;
      }
    }

    if(agcin==0)
      strcpy(buf,"dbbcgain=all,man");
    else
      strcpy(buf,"dbbcgain=all,agc");
    cls_snd(&out_class, buf, strlen(buf) , 0, 0);
    out_recs++;

    if(out_recs!=0) {
      ip[0]=8;
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
