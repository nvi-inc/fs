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
/* chekr DAS rack routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 513

void dbbcchk_( char *lwho )
{
  int ip[5];
  int i,ierr;
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE];
  int out_recs, out_class;
  char outbuf[BUFSIZE];
  int ichold;
  struct dbbcvsi_clk_mon lclm;

  ichold=shm_addr->check.dbbc_form;
  if(ichold<=0 )
    return; /* check is disabled */

  out_recs=0;
  out_class=0;
  strcpy(outbuf,"version");
  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
  out_recs++;

dbbcn:

  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;

  nsem_take( "fsctl" , 0 );
  skd_run("dbbcn",'w',ip);
  nsem_put( "fsctl" );

  skd_par(ip);


  if(ip[2]<0) {
    logita(NULL,ip[2],ip+3,ip+4);
    logit(NULL,-810,lwho);
    return;
  }

  ierr=0;
  for (i=0;i<ip[1];i++) {
    if ((nchars =
	 cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
      logit(NULL,-811,lwho);
      goto end;
    }
    inbuf[nchars]=0;
    /*                12345678 */
    if(strncmp(inbuf,"version/",8)==0) {
      ierr=dbbc_version_check(inbuf,NULL);
      if(ierr!=0 && ichold == shm_addr->check.dbbc_form) {
	logit(NULL,-813,lwho);
	goto end;
      }
    } else {
      logit(NULL,-814,lwho);
      goto end;
    }
  }

  /* only check vsi_clk if we verified the vesion number and is >= 107 */

  if(shm_addr->dbbcddcv>=107 &&
     (shm_addr->equip.rack_type == DBBC_DDC ||
      shm_addr->equip.rack_type == DBBC_DDC_FILA10G) ) {
    out_recs=0;
    out_class=0;
    strcpy(outbuf,"vsi_clk");
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;
    
dbbcn1:

    ip[0]=1;
    ip[1]=out_class;
    ip[2]=out_recs;
    
    nsem_take( "fsctl" , 0 );
    skd_run("dbbcn",'w',ip);
    nsem_put( "fsctl" );
    
    skd_par(ip);


    if(ip[2]<0) {
      logita(NULL,ip[2],ip+3,ip+4);
      logit(NULL,-810,lwho);
      return;
    }

    ierr=0;
    for (i=0;i<ip[1];i++) {
      if ((nchars =
	   cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	logit(NULL,-811,lwho);
	goto end;
      }
      inbuf[nchars]=0;
      if(dbbc_2_vsi_clk(&lclm,inbuf)
	 || !lclm.vsi_clk.state.known || lclm.vsi_clk.state.error) {
	logit(NULL,-815,lwho);
	goto end;
      }
      if(lclm.vsi_clk.vsi_clk!=shm_addr->m5b_crate) {
	logit(NULL,-816,lwho);
	goto end;
      }
    }
  }	

  return;

  end:
    if(i<ip[1]-1)
      cls_clr(ip[0]);
    return;

  }
