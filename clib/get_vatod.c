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
/* get a/d channels for VLBA narrow track heads */
/* channels are choosen to be synonymous with Mark III */

#include <sys/types.h>
#include <sys/times.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static int rel_addr[ ]   ={0x51,0x54,0x52,0x55,0x57,0x53,0x56,0x58};
    /* rel_addr gives the VLBA monitor point for the equiv. M3 channel */
    /* except for channel 1 and 2 with the LVDT on, this requires active */
    /*     measurement */
static int rel_addr_v2[ ]={0,0,0,0,0,0x60,0x61,0};

void get_vatod(ichan,volts,ip,indxtp)
int ichan;                           /* M3 style channel number */
float *volts;                        /* pointer to store result */
int ip[5];                          /* ipc array */
int indxtp;
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
      int counts;
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

      if(ichan<1 || ichan >(sizeof(rel_addr)/sizeof(int)) ||
        (((shm_addr->equip.drive[indx]==VLBA &&
	 shm_addr->equip.drive_type[indx] == VLBA2)||
	 (shm_addr->equip.drive[indx]==VLBA4 &&
	  shm_addr->equip.drive_type[indx] == VLBA42))
	 && rel_addr_v2[ichan-1] == 0) ) {
          ip[0]=ip[1]=0;
          ip[2]=-283;
          memcpy(ip+3,"q@",2);
          ip[4]=0;
          return;
      }

      ini_req(&buffer);                      /* format the buffer */
      if(indx == 0) 
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);
      request.type=1; 

      if(shm_addr->klvdt_fs[indx] && (ichan == 1 || ichan ==2)) {
        lvdonn_v(1,ip,indxtp);
        if(ip[2]<0) return;
        rte_sleep( 5);
      } 

      if ((shm_addr->equip.drive[indx] == VLBA &&
	  shm_addr->equip.drive_type[indx] == VLBA2)||
	  (shm_addr->equip.drive[indx] == VLBA4 &&
	   shm_addr->equip.drive_type[indx] == VLBA42))
        request.addr=rel_addr_v2[ichan-1];
      else
        request.addr=rel_addr[ichan-1];

      add_req(&buffer,&request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      counts=0xFFF & response.data;
      if((counts & 0x800)!=0) counts|=~0xFFF;   /*sign extend */
      if ((shm_addr->equip.drive[indx] == VLBA &&
	  shm_addr->equip.drive_type[indx] == VLBA2)||
	  (shm_addr->equip.drive[indx] == VLBA4 &&
	   shm_addr->equip.drive_type[indx] == VLBA42))
	*volts=counts*0.4e-3;
      else
	*volts=counts*4.8828125e-3;

      ip[0]=ip[1]=ip[4]=ip[2]=0;
      memcpy(ip+3,"q@",2);

      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-284;
        return;
      } 

       clr_res(&buffer_out);
       return;
}
