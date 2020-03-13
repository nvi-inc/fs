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
/* tpi_dbbc formats the buffers and runs dbbcn to get data */
/* tpput_dbbc stores the result in fscom and formats the output */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define BUFSIZE 512
    
int tpget_dbbc3(cont,ip,itpis_dbbc3,ierr,tpi,tpi2)/* put results of tpi & tpi2 */
int cont[MAX_DBBC3_DET];                          /* non-zero is continuous */
int ip[5];                                    /* ipc array */
int itpis_dbbc3[MAX_DBBC3_DET]; /* device selection array, see tpi_dbbc for details */
int *ierr;
float tpi[MAX_DBBC3_DET],tpi2[MAX_DBBC3_DET];
{
    int i;
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    char inbuf[BUFSIZE];


    for (i=0;i<MAX_DBBC3_BBC;i++) {
      if(1==itpis_dbbc3[i] || 1==itpis_dbbc3[i+MAX_DBBC3_BBC]) { /* bbc(s) */
	struct dbbc3_bbcnn_cmd lclc;
	struct dbbc3_bbcnn_mon lclm;
	int tpon[2],tpoff[2];

	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(i<ip[1]-1) 
	    cls_clr(ip[0]);
	  *ierr=-113;
	  return -1;
	}
	inbuf[nchars]=0;

	tpon[1]=-1;
	tpon[0]=-1;
	tpoff[1]=-1;
	tpoff[0]=-1;
	if(dbbc3_2_bbcnn(&lclc,&lclm,inbuf) ==0) {
	  tpon[1]=lclm.tpon[1];
	  tpon[0]=lclm.tpon[0];
	  tpoff[1]=lclm.tpoff[1];
	  tpoff[0]=lclm.tpoff[0];
	}
	if(1==itpis_dbbc3[i]) {
	  if(cont[i]) {
	    tpi[i]=tpoff[1];
	    tpi2[i]=tpon[1];
	  } else
	    tpi[i]=tpon[1];
	}
	if(1==itpis_dbbc3[i+MAX_DBBC3_BBC])
	  if(cont[i+MAX_DBBC3_BBC]) {
	    tpi[i+MAX_DBBC3_BBC]=tpoff[0];
	    tpi2[i+MAX_DBBC3_BBC]=tpon[0];
	  } else
	    tpi[i+MAX_DBBC3_BBC]=tpon[0];
      }
    }
    for (i=2*MAX_DBBC3_BBC;i<MAX_DBBC3_DET;i++) {
      if(1==itpis_dbbc3[i]) {                                 /* ifd(s): */
	struct dbbc3_iftpx_mon lclm;

	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  if(i<ip[1]-1) 
	    cls_clr(ip[0]);
	  *ierr=-114;
	  return -1;
	}
	inbuf[nchars]=0;

	tpi2[i]=-1;
	if( dbbc3_2_iftpx(&lclm,inbuf) !=0)
	  tpi[i]=-1;
	else
	  if(cont[i]) {
	    tpi[i]=lclm.off;
	    tpi2[i]=lclm.on;
	  } else
	    tpi[i]=lclm.tp;
      }
    }
    return 0;
}
