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
/* chekr formatter decode */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void vform_brk(ip,icherr,ierr)
int ip[5];
int icherr[5];
int *ierr;
{
  struct vform_cmd lclc;
  struct vform_cmd lcomm;
  int i,j, itracks[ 32], codes;
  struct res_buf buff_out;
  struct res_rec response;
  void get_res();

  opn_res(&buff_out,ip);
  get_res(&response,&buff_out);
  get_res(&response,&buff_out);

  for(i=0;i<32;i++) {                  /* get the track assignments */
      get_res(&response,&buff_out);
      itracks[i]=response.data;
  }
  mcD2vform(&lclc,itracks);

  get_res(&response,&buff_out); mc8Dvform(&lclc,response.data);
  get_res(&response,&buff_out); mc8Evform(&lclc,response.data);
  get_res(&response,&buff_out); mc8Fvform(&lclc,response.data);
  get_res(&response,&buff_out); mc90vform(&lclc,response.data);
  get_res(&response,&buff_out); mc91vform(&lclc,response.data);
  get_res(&response,&buff_out); mc92vform(&lclc,response.data);
  get_res(&response,&buff_out); mc93vform(&lclc,response.data);
  get_res(&response,&buff_out); mc99vform(&lclc,response.data);
  get_res(&response,&buff_out); mc9Avform(&lclc,response.data);
  get_res(&response,&buff_out); mcADvform(&lclc,response.data);

  if(response.state == -1) {
     clr_res(&buff_out);
     *ierr=-200;
     return;
  }
  clr_res(&buff_out);

  memcpy(&lcomm,&shm_addr->vform,sizeof(lcomm));

  codes = TRUE;
  for (i=0;i<32;i++)
    codes &= lcomm.codes[i] == lclc.codes[i];

  if (!codes) icherr[0]=1;
  if (lcomm.rate != lclc.rate) icherr[1]=1;
  if (lcomm.format != lclc.format) icherr[2]=1;
  if (lcomm.enable.low    != lclc.enable.low ||
      lcomm.enable.high   != lclc.enable.high ||
      lcomm.enable.system != lclc.enable.system) icherr[3]=1;
  if (lcomm.qa.drive != lclc.qa.drive ||
      lcomm.qa.chan  != lclc.qa.chan) icherr[4]=1;

  return;

}
