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
/* chekr ifd mcbcn return decoder */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void dist_brk(imod,ip,icherr,ierr)
int *imod;
int ip[5];
int icherr[5];
int *ierr;
{
  struct dist_cmd lclc;
  struct dist_mon lclm;
  struct dist_cmd lcomm;
  int ind, ich, count;
  struct res_buf buffer;
  struct res_rec response;
  void opn_res();
  void get_res();
  void mc01dist(), mc02dist();

  ind=*imod-1;

  opn_res(&buffer,ip);
  get_res(&response, &buffer); mc01dist(&lclc, response.data);
  get_res(&response, &buffer); mc02dist(&lclc, response.data);
  get_res(&response, &buffer); mc06dist(&lclm, response.data);
  get_res(&response, &buffer); mc07dist(&lclm, response.data);
  if (response.state == -1) {
    shm_addr->vifd_tpi[2*ind+0]=65536;
    shm_addr->vifd_tpi[2*ind+1]=65536;
     clr_res(&buffer);
     *ierr=-200;
     return;
  }

  clr_res(&buffer);

  memcpy(&lcomm,&shm_addr->dist[ind],sizeof(lcomm));

  if (lcomm.atten[0] != lclc.atten[0]) icherr[0]=1;
  if (lcomm.atten[1] != lclc.atten[1]) icherr[1]=1;
  if (lcomm.input[0] != lclc.input[0]) icherr[2]=1;
  if (lcomm.input[1] != lclc.input[1]) icherr[3]=1;
  if (lcomm.avper != lclc.avper) icherr[4]=1;
  shm_addr->vifd_tpi[2*ind+0]=lclm.totpwr[0];
  shm_addr->vifd_tpi[2*ind+1]=lclm.totpwr[1];

  return;
}
