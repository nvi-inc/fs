/*
 * Copyright (c) 2020, 2023, 2026 NVI, Inc.
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

static char ifds[ ]={"abcdefgh"};
static struct dbbc3_ifx_cmd savec[MAX_DBBC3_IF];;

int agc_dbbc3(itpis_dbbc3,agcin,ierr)                    /* sample tpi(s) */
int itpis_dbbc3[MAX_DBBC3_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc16, U: bbc1...bbc16(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int agcin;              /* value to send 0=fixed,1=before fixed */
int *ierr;
{
  struct dbbc3_ifx_cmd lclc;
  struct dbbc3_ifx_mon lclm;
  static int mode[MAX_DBBC3_IF];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char buf[BUFSIZE];
  int out_recs, out_class;
  int i, ifchain, j, ifc;
  int ip[5];                                     /* ipc array */
  static int bbcs;

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
          }
      }

      for (i=0;i<MAX_DBBC3_IF;i++) {
	if(!mode[i] && 1==itpis_dbbc3[i+2*MAX_DBBC3_BBC]) {
	  mode[i]=1;
	}
      }

    /* read back current if set-up */

      out_recs=0;
      out_class=0;

      for (i=0;i<MAX_DBBC3_IF;i++) {
          if(mode[i]) {
              sprintf(buf,"dbbcif%c",ifds[i]);
              cls_snd(&out_class, buf, strlen(buf) , 0, 0);
              out_recs++;

          }
      }
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

      int nrecs=ip[1];
      int ifc=-1;
      for (i=0;i<nrecs;i++) {
          if ((nchars =
                      cls_rcv(ip[0],buf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
              ip[2] =  -401;
              memcpy(ip+3,"nf",2);
              return;
          }
          buf[nchars]=0;
          for(j=ifc+1;j<MAX_DBBC3_IF;j++)
              if(mode[j]) {
                  ifc=j;
                  break;
              }

          if( dbbc3_2_ifx(savec+ifc,&lclm,buf) !=0) {
              ip[2] = -402;
              memcpy(ip+3,"nf",2);
              if(i<nrecs-1)
                  cls_clr(ip[0]);
              return;
          }
      }
    }

    out_recs=0;
    out_class=0;
    for(i=0;i<MAX_DBBC3_IF;i++)
        if(mode[i] & savec[i].agc==1) {
            if(agcin==0)
                savec[i].target_null=1;
            else
                savec[i].att=-1;
            ifx_2_dbbc3(buf,i+1,savec+i);
            cls_snd(&out_class, buf, strlen(buf) , 0, 0);
            out_recs++;
        }


    if(bbcs) {
        if(agcin==0)
            strcpy(buf,"dbbcgain=all,man");
        else
            strcpy(buf,"dbbcgain=all,agc");
        cls_snd(&out_class, buf, strlen(buf) , 0, 0);
        out_recs++;
    }

    if(out_recs!=0) {
      ip[0]=8;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      cls_clr(ip[0]);
      if(ip[2]<0) {
	logita(NULL,ip[2],ip+3,ip+4);
	*ierr=-10;
	return -1;
      }
    }

    return 0;
}
