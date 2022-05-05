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
/* check to make sure motion is done and voltage is updated */

#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static chekr=0;

void set_chekr_v2_motion_done__()
{
  
  chekr=1;
}

int v2_motion_done(ip,indx)
int ip[5];                          /* ipc array */
int indx;
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
      int counts,motion, oorange, time_out;
      struct tms tms_buff;
      int end;

      ini_req(&buffer);                      /* format the buffer */
      if(indx == 0) 
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);
      request.type=1; 
      request.addr=0x74; add_req(&buffer,&request);
      request.addr=0x73; add_req(&buffer,&request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */

      get_res(&response, &buffer_out);
      oorange=(0x1&response.data) != 0;     /* command out of range */
      time_out = ((1 << 9) & response.data) != 0;

      get_res(&response, &buffer_out);
      motion=(0x10&response.data) != 0;     /* still moving */

      /* kludge for VLBA42 */
      if (chekr && motion !=0 &&
	  (shm_addr->equip.drive[indx] == VLBA4 &&
	   shm_addr->equip.drive_type[indx] == VLBA42)) {
	motion=0;
	logita(NULL,-288,"q@","  ");
      }

      ip[0]=ip[1]=ip[4]=ip[2]=0;
      memcpy(ip+3,"q@",2);

      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-292;
        return TRUE;
      } else if (oorange)
	ip[2]=-289;
      else if (motion)
        ip[2]=-288;
      else if (time_out)
	ip[2]=-290;

      clr_res(&buffer_out);
      return (!motion) | oorange;
}
