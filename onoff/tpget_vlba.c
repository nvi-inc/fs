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

int tpget_vlba(ip,itpis_vlba,ierr,tpi) /* get results of tpi */
int ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
int *ierr;
float tpi[MAX_DET]; /* detector value array */
{
    struct res_buf buffer_out;
    struct res_rec response;
    int i;

    opn_res(&buffer_out,ip);

    for (i=0;i<MAX_DET;i++) {
      if(itpis_vlba[ i] == 1) {
	get_res(&response,&buffer_out);
	if(response.code==1)
	  tpi[i]=response.data;
	else
	  tpi[i]=response.code;
      }
    }

    if(response.state == -1) {
       clr_res(&buffer_out);
       *ierr=-11;
       return -1;
    }
    clr_res(&buffer_out);

    return 0;
}

