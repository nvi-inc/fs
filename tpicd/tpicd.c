/*
 *  HISTORY:
 *  WHO  WHEN    WHAT
 *  weh  020503  cloned from pcald.c
 */

#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_BUF 256

extern struct fscom *shm_addr;

static char *lvcn[]= { "v1","v2","v3","v4","v5","v6","v7","v8","v9","va", 
	       "vb","vc","vd","ve","vf" };
double dbbc_if_power(unsigned counts, int como);

main()
{
  long ip[5];
  struct tpicd_cmd tpicd;
  struct data_valid_cmd data_valid[2];
  struct dbbc_cont_cal_cmd dbbc_cont_cal;
  int i,j,k,l,idata,nch,ilen, nchstart, nchar;
  char buff[120];
  unsigned before,after,isleep;

  long int ierr;
  int iclass,nrec,idum,nr;
  short int buf2[80];
  char buf3[MAX_BUF];

  int samples;
  double dbbc_tpi[MAX_DBBC_DET],dbbc_tpical[MAX_DBBC_DET];

/* connect to the FS */

  putpname("tpicd");
  setup_ids();
 
  if(shm_addr->equip.rack==VLBA || shm_addr->equip.rack==VLBA4) {
    strcpy(buff,"tpgain/");
    nchstart=nch=strlen(buff)+1;
  } else if(shm_addr->equip.rack==MK3 || shm_addr->equip.rack==MK4 ||
            shm_addr->equip.rack==LBA4) {
    strcpy(buff,"tpi/");
    nchstart=nch=strlen(buff);
  } else if(shm_addr->equip.rack==LBA) {
    strcpy(buff,"tpi/");
    nchstart=nch=strlen(buff)+1;
  }

 loop:
#ifdef TESTX
  printf(" sleeping\n");
#endif
  skd_wait("tpicd",ip,0);

#ifdef TESTX
  printf(" woke-up\n");
#endif

 wakeup_block:
  memcpy(&tpicd,&shm_addr->tpicd,sizeof(tpicd));
  shm_addr->tpicd.tsys_request=0;
  memcpy(&data_valid,&shm_addr->data_valid,sizeof(data_valid));
  memcpy(&dbbc_cont_cal,&shm_addr->dbbc_cont_cal,sizeof(dbbc_cont_cal));

  if(dbbc_cont_cal.mode==1) {
    samples=0;
    for(i=0;i<MAX_DBBC_DET;i++) {
      dbbc_tpi[i]=0.0;
      dbbc_tpical[i]=0.0;
    }
  }

  if(shm_addr->equip.rack==DBBC) {
    if(dbbc_cont_cal.mode==1)
      strcpy(buff,"tpcont/");
    else
      strcpy(buff,"tpi/");
    nchstart=nch=strlen(buff)+1;
  }

#ifdef TESTX
  printf(" copied structures\n");
#endif
  if(tpicd.stop_request!=0 && tpicd.tsys_request == 0)
    goto loop;
  
#ifdef TESTX
  printf(" not stopped\n");
#endif
  if(tpicd.continuous==0 && tpicd.tsys_request==0 &&
     (data_valid[0].user_dv ==0 && data_valid[1].user_dv ==0))
    goto loop;

  if(tpicd.cycle<=0)
    goto loop;

#ifdef TESTX
  printf(" continuous %d data_valid[0] %d data_valid[1] %d tpicd.cycle %d\n",
	 tpicd.continuous,data_valid[0].user_dv,data_valid[1].user_dv,
	 tpicd.cycle);
#endif

  idata=0;
  for(i=0;i<2*MAX_BBC+4;i++)
    if(tpicd.itpis[i]!=0)
      idata=1;

  if (!idata)
    goto loop;
  
#ifdef TESTX
  printf(" there is data to collect\n");
#endif

  skd_end(ip);

/* extract forever until some one wakes up */

  while(TRUE) {

#ifdef TESTX
    printf(" collecting data \n");
#endif

    rte_rawt(&before);
    if(shm_addr->equip.rack==VLBA || shm_addr->equip.rack==VLBA4) {
      tpi_vlba(ip,tpicd.itpis,8);   /* sample tpgain(s) */
      tpput_vlba(ip,tpicd.itpis,-8,buff,&nch,ilen); /* put results of tpi */
    } else if(shm_addr->equip.rack==MK3 || shm_addr->equip.rack==MK4 ||
              shm_addr->equip.rack==LBA4) {
      iclass=0;
      nrec=0;
      for(i=0;i<17;i++) {
	if(tpicd.itpis[i]!=0 &&
	   (i!=15||(i==15&&tpicd.itpis[14]==0))) {
	  if(i<14) {
	    buf2[0]=-22;
	    memcpy(buf2+1,lvcn[i],2);
	  } else if(i==14 || i==15) {
	    buf2[0]=-21;
	    memcpy(buf2+1,"if",2);
	  } else {
	    buf2[0]=-22;
	    memcpy(buf2+1,"i3",2);
	  }
	  cls_snd(&iclass,buf2,4,0,0); nrec++;
	}
      }
      ip[0]=iclass;
      ip[1]=nrec;
      skd_run("matcn",'w',ip);
      skd_par(ip);
      nrec = ip[1];
      iclass = ip[0];
      nr=0;
      for(i=0;i<17;i++) {
	long ipwr;
	if (tpicd.itpis[i]==0)
	  continue;
	if(i!=15||tpicd.itpis[14]==0) {
	  if(nr>=nrec)
	    continue;
	  nchar=cls_rcv(iclass,&ierr,MAX_BUF,&idum,&idum,0,0);
	  nchar=cls_rcv(iclass,buf3,MAX_BUF,&idum,&idum,0,0);
	  nr=nr+2;
	}
	if(ierr>=0 && 1== sscanf(buf3+(i<=14?6:2),"%4x",&ipwr)) {
	  if(ipwr>=65535)
	    shm_addr->tpi[i+14]=1e9;
	  else 
	    shm_addr->tpi[i+14]=ipwr;
	} else if(ierr<0)
	  shm_addr->tpi[i+14]=ierr;
	else
	  shm_addr->tpi[i+14]=-9999;
      }

      buff[nchstart]=0;
      for(j=0;j<4;j++) {
	for(i=0;i<14;i++) {
	  if(tpicd.itpis[i]!=0&&tpicd.ifc[i]==j) {
	    if(strlen(buff)>60) {
	      buff[strlen(buff)-1]=0;
	      logit(buff,0,NULL);
	      buff[nchstart]=0;
	    }
	    sprintf(buff+strlen(buff),"%2.2s,%d,",
		    tpicd.lwhat[i],shm_addr->tpi[i+14]);
	  }
	}
	if(j!=0) {
	  if(tpicd.itpis[j+14-1]!=0) {
	    if(strlen(buff)>60) {
	      buff[strlen(buff)-1]=0;
	      logit(buff,0,NULL);
	      buff[nchstart]=0;
	    }
	    sprintf(buff+strlen(buff),"%2.2s,%d,",
		    tpicd.lwhat[j+14-1],shm_addr->tpi[j+28-1]);
	  }
	}
	if(strlen(buff)!=nchstart) {
	  buff[strlen(buff)-1]=0;
	  logit(buff,0,NULL);
	  buff[nchstart]=0;
	}
      }
    } else if(shm_addr->equip.rack==LBA) {
      tpi_lba(ip,tpicd.itpis);   /* sample tpi(s) */
      tpput_lba(ip,tpicd.itpis,-3,buff,&nch,ilen); /* put results of tpi */
    } else if(shm_addr->equip.rack==DBBC) {
#ifdef TESTX
    printf(" collecting dBBC data \n");
#endif
      tpi_dbbc(ip,tpicd.itpis);   /* sample tpi(s) */
      if(dbbc_cont_cal.mode!=1) {
#ifdef TESTX
    printf(" put non-cont dBBC data \n");
#endif
	tpput_dbbc(ip,tpicd.itpis,-3,buff,&nch,ilen); /* put results of tpi */
      } else {
#ifdef TESTX
    printf(" put cont dBBC data \n");
#endif
	tpput_dbbc(ip,tpicd.itpis,-11,buff,&nch,ilen); /* put tpcont */
	for(k=0;k<MAX_DBBC_DET;k++) {
	  if(1==tpicd.itpis[k]) {
	    if(dbbc_tpi[k]<-0.5 ||shm_addr->tpi[k]<=0 ||
	       shm_addr->tpi[k]>65534.5)
	      dbbc_tpi[k]=-1.0;
	    else if(k < MAX_DBBC_BBC*2)
	      dbbc_tpi[k]+=shm_addr->tpi[k];
	    else {
	      dbbc_tpi[k]+=dbbc_if_power(shm_addr->tpi[k], k-MAX_DBBC_BBC*2);
	    }
	    if(k >= MAX_DBBC_BBC*2)
	      continue;
	    if(dbbc_tpical[k]<-0.5 ||shm_addr->tpical[k]<=0
	       || shm_addr->tpical[k]>65534.5)
	      dbbc_tpical[k]=-1.0;
	    else
	      dbbc_tpical[k]+=shm_addr->tpical[k];
	  }
	}
	if(++samples >= dbbc_cont_cal.samples) {
	  int tsys_disp=tpicd.tsys_request;
	  tpicd.tsys_request=0;
	  cont_dbbc(tpicd.itpis,dbbc_tpi,dbbc_tpical,samples,3,tsys_disp);
	  cont_dbbc(tpicd.itpis,dbbc_tpi,dbbc_tpical,samples,4,tsys_disp);
	  cont_dbbc(tpicd.itpis,dbbc_tpi,dbbc_tpical,samples,10,tsys_disp);
	  cont_dbbc(tpicd.itpis,dbbc_tpi,dbbc_tpical,samples,5,tsys_disp);
	  samples=0;
	  for(i=0;i<MAX_DBBC_DET;i++) {
	    dbbc_tpi[i]=0.0;
	    dbbc_tpical[i]=0.0;
	  }
	  if(tsys_disp)
	    goto wakeup_block;
	}
      }
    }
    
#ifdef TESTX
    printf(" finished collecting \n");
#endif
    rte_rawt(&after);
    if(before <after && tpicd.cycle>after-before)
      isleep=tpicd.cycle-(after-before);
    else if (before < after && tpicd.cycle <= after-before)
      isleep=0;
    else
      isleep=tpicd.cycle;

    isleep++;
      
#ifdef TESTX
    printf(" isleep %d\n",isleep);
#endif
    skd_wait("tpicd",ip,isleep);

/* when I wake-up I goto the wake-up block if some one else woke me up */

	if(dad_pid()!=0) {
#ifdef TESTX
	  printf("some one woke me 1\n");
#endif
	  goto wakeup_block;
	}

  }

#ifdef TESTX
  printf("can't get here\n");
#endif
  exit(-1);

}  /* end main */
