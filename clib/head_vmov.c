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
/* move vlba head stack */

#include <sys/types.h>
#include <sys/times.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

clock_t rte_times(struct tms *);

void head_vmov(ihead,idir,ispdhd,jm,ip,indxtp)
int ihead;                     /* head 1-4 */
int idir;                      /* direction (0|1 = SLOW|FAST) */
int ispdhd;                    /* speed (0|1 = IN|OUT) */
int jm;                       /* duration in units of 40 microseconds */
                               /* already limited to 16 bits by caller */
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
      request.type=0;

      request.addr=0xC3; request.data=ihead & 0x3;   /* head */
      add_req(&buffer, &request);

                                                         /* motion primitive */
      request.addr=0xCC; request.data=(idir & 0x1)<< 1 | (ispdhd & 0x1);
      add_req(&buffer, &request);

      request.addr=0xCD; request.data=jm & 0xFFFF;       /* duration */
      add_req(&buffer, &request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);

      ip[0]=ip[1]=0;
      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-287;
        memcpy(ip+3,"q@",2);
        ip[4]=0;
        return;
      }

       clr_res(&buffer_out);
       ip[2]=0;

       rte_sleep( jm/250+2);    /* sleep at least as long at it might take */

       end=rte_times(&tms_buff)+200;    /* give it 2 more seconds to complete*/
       while(end>rte_times(&tms_buff) && !motion_done(ip,indx))
	;
       if(ip[2]<0) return;        /* error or still moving */

       rte_sleep(3);
       return;                    /* okay */
}
