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
/* tpi support utilities for LBA rack */
/* tpi_lba formats the buffers and runs mcbcn to get data */
/* tpput_lba stores the result in fscom and formats the output */
/* tsys_lba does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int lba_tpi_from_level(unsigned short level);

int tpget_lba(ip,itpis_lba,ierr,tpi) /* get results of tpi */
int ip[5];                                    /* ipc array */
int itpis_lba[2*MAX_DAS]; /* device selection array, see tpi_lba for details */
int *ierr;
float tpi[2*MAX_DAS]; /* detector value array */
{
    struct ds_mon lclm;
    int i;

    *ierr=0;
    for (i=0;i<2*shm_addr->n_das;i++) {
       if(itpis_lba[i] == 1) {
         if (dscon_rcv(&lclm,ip)) {
           if (shm_addr->das[i/2].ifp[0].initialised)
             shm_addr->das[i/2].ifp[0].initialised = -1;
           if (shm_addr->das[i/2].ifp[1].initialised)
             shm_addr->das[i/2].ifp[1].initialised = -1;
           *ierr=1;
           tpi[i]=lclm.resp;
         } else {
           tpi[i]=lba_tpi_from_level(lclm.data.value);
         }
       }
    }
    if (*ierr) {
       cls_clr(ip[0]);
       *ierr=-11;
       return -1;
    }
    clr_res(ip[0]);

    return 0;
}

