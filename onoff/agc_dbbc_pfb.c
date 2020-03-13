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

int agc_dbbc_pfb(itpis_dbbc_pfb,agcin,ierr)                    /* sample tpi(s) */
int itpis_dbbc_pfb[MAX_DBBC_PFB_DET]; /* detector selection array */
                      /* in order: core 1 (0:15), core 2 (0:15)       */
                      /*           core 3 (0:15), core 4 (0:15)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int agcin;              /* value to send 0=fixed,1=before fixed */
int *ierr;
{
  static int agc[MAX_DBBC_IF], att[MAX_DBBC_IF], mode[MAX_DBBC_IF];
  int i, j, icore, k,ifchain;
  int ip[5];                                     /* ipc array */
  int out_recs, out_class;
  char buf[BUFSIZE];

    if(agcin==0) {
      icore=0;
      for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	mode[i]=0;
	for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	  int found=0;
	  
	  icore++;
	  for(k=1;k<16 && !(found=itpis_dbbc_pfb[k+(icore-1)*16]);k++)
	    ;
	  if(found) {
	    ifchain=i+1;
	    mode[ifchain-1]=1;
	    agc[ifchain-1]=shm_addr->dbbcifx[ifchain-1].agc;
	    att[ifchain-1]=shm_addr->dbbcifx[ifchain-1].att;
	  }
	}

	if(!mode[i] && 1==itpis_dbbc_pfb[i+MAX_DBBC_PFB]) {
	  mode[i]=1;
	  agc[i]=shm_addr->dbbcifx[i].agc;
	  att[i]=shm_addr->dbbcifx[i].att;
	}
      }
    }

    out_recs=0;
    out_class=0;

    for (i=0;i<shm_addr->dbbc_cond_mods;i++) {
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
