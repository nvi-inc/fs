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
/* turn off lvdt for vlba recorder */

#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void lvdofn_v(ip,indxtp)
int ip[5];
int indxtp;
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
      int indx;

      if(indxtp == 1) {
	indx=0;
      } else if(indxtp == 2) {
	indx=1;
      } else {
	ip[2]=-505;
	memcpy("q<",ip+4,2);
	return;
      }

      if(shm_addr->reccpu[indx]==162) {
	ip[0]=ip[1]=ip[2]=0;
	return;
      }
      shm_addr->klvdt_fs[indx]=0;
      ini_req(&buffer);                      /* format the buffer */
      if(indx == 0)
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);
      request.type=0;
      request.addr=0xE0; request.data=0xB0  ; add_req(&buffer,&request);
      request.addr=0xE1; request.data=0x12  ; add_req(&buffer,&request);

                                             /* or bit ON to turn off LVDT */
      request.addr=0xE3; request.data=0x0100; add_req(&buffer,&request);

      end_req(ip,&buffer);                /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);            /* check for correct # of reponses */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[0]=ip[1]=0;
        ip[2]=-286;
        memcpy(ip+3,"q@",2);
        ip[4]=0;
        return;
      }

       clr_res(&buffer_out);
       ip[0]=ip[1]=ip[2]=0;
       return;
}



