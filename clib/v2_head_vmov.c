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
/* move vlba2 head stack */

#include <sys/types.h>
#include <sys/times.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

clock_t rte_times(struct tms *);

void v2_head_vmov(ihead,volt,ip,indxtp)
int ihead;                     /* head 1-4 */
float volt;                    /* voltage to set head to */
int ip[5];                    /* ipc array */
int indxtp;
{
      struct req_buf buffer;           /* request buffer */
      struct req_rec request;          /* reqeust record */
      struct res_buf buffer_out;       /* response buffer */
      struct res_rec response;         /* respones record */
      struct tms tms_buff;
      int end;
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
      ini_req(&buffer);                /* initialize */
      if(indx == 0)
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);

      request.type=1;         /* clear out-of-range bit before we start */
      request.addr=0x74;
      add_req(&buffer, &request);

      request.type=0;

      request.addr=0xC3; request.data=ihead & 0x3;   /* head */
      add_req(&buffer, &request);
                                                     /* motion */
      request.addr=0xC6; 
      if(volt >0)
        request.data=volt+.5;
      else if (volt <0)
        request.data=volt-.5;
      add_req(&buffer, &request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);

      ip[0]=ip[1]=0;
      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-294;
        memcpy(ip+3,"q@",2);
        ip[4]=0;
        return;
      }

       clr_res(&buffer_out);
       ip[2]=0;

       rte_sleep( 12); /*wait for vlba2 drive to set "moving" bit on */

       end=rte_times(&tms_buff)+1502;  /* give it at most 15 seconds to complete*/
       while(end>rte_times(&tms_buff) && !v2_motion_done(ip,indx))
           rte_sleep(50);
       if(ip[2]<0) return;        /* error or still moving */

       return;                    /* okay */
}
