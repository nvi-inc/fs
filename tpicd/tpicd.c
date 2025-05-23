/*
 * Copyright (c) 2020, 2022, 2023, 2025 NVI, Inc.
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
  int ip[5];
  struct tpicd_cmd tpicd;
  struct data_valid_cmd data_valid[2];
  struct dbbc_cont_cal_cmd dbbc_cont_cal;
  struct dbbc3_cont_cal_cmd dbbc3_cont_cal;
  int i,j,k,l,idata,nch,ilen, nchstart, nchar;
  char buff[120];
  unsigned before,after,isleep;

  int ierr;
  int iclass,nrec,idum,nr;
  short int buf2[80];
  char buf3[MAX_BUF];

  int samples;
  double dbbc_tpi[MAX_DBBC_DET],dbbc_tpical[MAX_DBBC_DET];
  double dbbc3_tpi[MAX_DBBC3_DET],dbbc3_tpical[MAX_DBBC3_DET];

  struct rdtcn_control rdtcn_control[MAX_RDBE];
  struct dbtcn_control dbtcn_control;
  int iping[MAX_RDBE];

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
  } else if(shm_addr->equip.rack==DBBC &&
     (shm_addr->equip.rack_type == DBBC_PFB ||
      shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
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
  memcpy(&dbbc3_cont_cal,&shm_addr->dbbc3_cont_cal,sizeof(dbbc3_cont_cal));

  if(RDBE == shm_addr->equip.rack) {
    for(i=0;i<MAX_RDBE;i++) {
      rdtcn_control[i].continuous=shm_addr->tpicd.continuous;
      rdtcn_control[i].cycle=shm_addr->tpicd.cycle;
      rdtcn_control[i].stop_request=shm_addr->tpicd.stop_request;
      memcpy(&rdtcn_control[i].data_valid,&data_valid,
	     sizeof(struct data_valid_cmd));
      iping[i]=1-shm_addr->rdtcn[i].iping;
      if(iping[i]!=0)
	iping[i]=1;
      memcpy(&shm_addr->rdtcn[i].control[iping[i]],&rdtcn_control,
	     sizeof(struct rdtcn_control));
      shm_addr->rdtcn[i].iping=iping[i];
    }
    goto loop;
  } else if(DBBC3 == shm_addr->equip.rack) {
      dbtcn_control.continuous=tpicd.continuous;
      dbtcn_control.cycle=tpicd.cycle;
      dbtcn_control.reset_request=ip[0];
      dbtcn_control.stop_request=tpicd.stop_request;
      dbtcn_control.tsys_request=tpicd.tsys_request;
      memcpy(&dbtcn_control.data_valid,&data_valid,
	     sizeof(struct data_valid_cmd));
      iping[0]=1-shm_addr->dbtcn.iping;
      if(iping[0]!=0)
	iping[0]=1;
      memcpy(&shm_addr->dbtcn.control[iping[0]],&dbtcn_control,
	     sizeof(struct dbtcn_control));
      shm_addr->dbtcn.iping=iping[0];
    goto loop;
  }

  if(shm_addr->equip.rack==DBBC &&
     (shm_addr->equip.rack_type == DBBC_DDC ||
      shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) { /* continuous or not
							   can change between
							   iterations */
    if(dbbc_cont_cal.mode==1) {
      samples=0;
      for(i=0;i<MAX_DBBC_DET;i++) {
	dbbc_tpi[i]=0.0;
	dbbc_tpical[i]=0.0;
      }
    }
    if(dbbc_cont_cal.mode==1)
      strcpy(buff,"tpcont/");
    else
      strcpy(buff,"tpi/");
    nchstart=nch=strlen(buff)+1;
  } else if(shm_addr->equip.rack==DBBC3) {
    if(dbbc3_cont_cal.mode==1) {
      samples=0;
      for(i=0;i<MAX_DBBC3_DET;i++) {
	dbbc3_tpi[i]=0.0;
	dbbc3_tpical[i]=0.0;
      }
    }
    if(dbbc3_cont_cal.mode==1)
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
     ((data_valid[0].user_dv ==0 && data_valid[1].user_dv ==0)||
      shm_addr->KHALT !=0 || 0==strncmp(shm_addr->LSKD2,"     ",5)))
    goto loop;

  if(tpicd.cycle<=0)
    goto loop;

#ifdef TESTX
  printf(" continuous %d data_valid[0] %d data_valid[1] %d tpicd.cycle %d\n",
	 tpicd.continuous,data_valid[0].user_dv,data_valid[1].user_dv,
	 tpicd.cycle);
#endif

  idata=0;

  if(shm_addr->equip.rack==VLBA || shm_addr->equip.rack==VLBA4) {
    for(i=0;i<2*MAX_DET;i++)
      if(tpicd.itpis[i]!=0)
	idata=1;
  } else if(shm_addr->equip.rack==MK3 || shm_addr->equip.rack==MK4 ||
	    shm_addr->equip.rack==LBA4||shm_addr->equip.rack==LBA) {
    for(i=0;i<2*MAX_VC+3;i++)
      if(tpicd.itpis[i]!=0)
	idata=1;
  } else if(shm_addr->equip.rack==DBBC) {  
    for(i=0;i<2*MAX_DBBC_DET;i++)
      if(tpicd.itpis[i]!=0)
	idata=1;
  } else if(shm_addr->equip.rack==DBBC3) {  
    for(i=0;i<2*MAX_DBBC3_DET;i++)
      if(tpicd.itpis[i]!=0)
	idata=1;
  }
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
	int ipwr;
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
    } else if(shm_addr->equip.rack==DBBC &&
	      (shm_addr->equip.rack_type == DBBC_DDC ||
	       shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
#ifdef TESTX
      printf(" collecting dBBC data \n");
#endif
      tpi_dbbc(ip,tpicd.itpis);   /* sample tpi(s) */
      if(ip[2]<0) {
	logita(NULL,ip[2],ip+3,ip+4);
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	logit(NULL,-1,"cd");
	goto while_end;
      }
      if(dbbc_cont_cal.mode!=1) { /* non-continuous cal */
#ifdef TESTX
	printf(" put non-cont dBBC data \n");
#endif
	tpput_dbbc(ip,tpicd.itpis,-3,buff,&nch,ilen); /* put results of tpi */
	if(ip[2]<0) {
	  logit(NULL,ip[2],ip+3);
	  if(ip[0]!=0) {
	    cls_clr(ip[0]);
	    ip[0]=ip[1]=0;
	  }
	  logit(NULL,-2,"cd");
	  goto while_end;
	}
      } else { /* continuous cal */
#ifdef TESTX
	printf(" put cont dBBC data \n");
#endif
	tpput_dbbc(ip,tpicd.itpis,-11,buff,&nch,ilen); /* put tpcont */
	if(ip[2]<0) {
	  logit(NULL,ip[2],ip+3);
	  if(ip[0]!=0) {
	    cls_clr(ip[0]);
	    ip[0]=ip[1]=0;
	  }
	  logit(NULL,-2,"cd");
	  goto while_end;
	}
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
    } else if(shm_addr->equip.rack==DBBC &&
	      (shm_addr->equip.rack_type == DBBC_PFB ||
	       shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
#ifdef TESTX
      printf(" collecting dBBC PFB data \n");
#endif
      tpi_dbbc_pfb(ip,tpicd.itpis);   /* sample tpi(s) */
      if(ip[2]<0) {
	logita(NULL,ip[2],ip+3,ip+4);
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	logit(NULL,-1,"cd");
	goto while_end;
      }
#ifdef TESTX
      printf(" put non-cont dBBC data \n");
#endif
      tpput_dbbc_pfb(ip,tpicd.itpis,-3,buff,&nch,ilen); /* put results of tpi */
      if(ip[2]<0) {
	logit(NULL,ip[2],ip+3);
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	logit(NULL,-2,"cd");
	goto while_end;
      }
    } else if(shm_addr->equip.rack==DBBC3) {
#ifdef TESTX
    printf(" collecting dBBC3 data \n");
#endif
      tpi_dbbc3(ip,tpicd.itpis);   /* sample tpi(s) */
      if(ip[2]<0) {
	logita(NULL,ip[2],ip+3,ip+4);
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	logit(NULL,-1,"cd");
	goto while_end;
      }
      if(dbbc3_cont_cal.mode!=1) {
#ifdef TESTX
    printf(" put non-cont dBBC3 data \n");
#endif
	tpput_dbbc3(ip,tpicd.itpis,-3,buff,&nch,ilen); /* put results of tpi */
      } else {
#ifdef TESTX
    printf(" put cont dBBC3 data \n");
#endif
	tpput_dbbc3(ip,tpicd.itpis,-11,buff,&nch,ilen); /* put tpcont */
	for(k=0;k<MAX_DBBC3_DET;k++) {
	  if(1==tpicd.itpis[k]) {
	    if(dbbc3_tpi[k]<-0.5 ||shm_addr->tpi[k]<=0 ||
	       shm_addr->tpi[k]>65534.5)
	      dbbc3_tpi[k]=-1.0;
	    else {
	      dbbc3_tpi[k]+=shm_addr->tpi[k];
	    }
	    if(dbbc3_tpical[k]<-0.5 ||shm_addr->tpical[k]<=0
	       || shm_addr->tpical[k]>65534.5)
	      dbbc3_tpical[k]=-1.0;
	    else
	      dbbc3_tpical[k]+=shm_addr->tpical[k];
	  }
	}
	if(++samples >= dbbc3_cont_cal.samples) {
	  int tsys_disp=tpicd.tsys_request;
	  tpicd.tsys_request=0;
	  cont_dbbc3(tpicd.itpis,dbbc3_tpi,dbbc3_tpical,samples,3,tsys_disp);
	  cont_dbbc3(tpicd.itpis,dbbc3_tpi,dbbc3_tpical,samples,4,tsys_disp);
	  cont_dbbc3(tpicd.itpis,dbbc3_tpi,dbbc3_tpical,samples,10,tsys_disp);
	  cont_dbbc3(tpicd.itpis,dbbc3_tpi,dbbc3_tpical,samples,5,tsys_disp);
	  samples=0;
	  for(i=0;i<MAX_DBBC3_DET;i++) {
	    dbbc3_tpi[i]=0.0;
	    dbbc3_tpical[i]=0.0;
	  }
	  if(tsys_disp)
	    goto wakeup_block;
	}
      }
    }
   
  while_end:
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
