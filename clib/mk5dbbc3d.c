/*
 * Copyright (c) 2020-2021 NVI, Inc.
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
/* mk5dbbc3d.c make list of bbc detectors needed for DBBC3_DDCx rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk5dbbc3d(itpis)
int itpis[MAX_DBBC3_DET];
{
    int i, j;
    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {

        if(shm_addr->dbbc3_core3h_modex[i].mask1.state.known)
            for (j=0;j<8;j++) {
                if(shm_addr->dbbc3_core3h_modex[i].mask1.mask1 & 0xcu<<j*4) {
                    itpis[i*8+j]=1;
                }
                if(shm_addr->dbbc3_core3h_modex[i].mask1.mask1 & 0x3u<<j*4) {
                    itpis[i*8+j+MAX_DBBC3_BBC]=1;
                }
            }

        if(shm_addr->dbbc3_core3h_modex[i].mask2.state.known)
            for (j=0;j<8;j++) {
                if(shm_addr->dbbc3_core3h_modex[i].mask2.mask2 & 0xcu<<j*4) {
                    itpis[i*8+j+MAX_DBBC3_BBC/2]=1;
                }
                if(shm_addr->dbbc3_core3h_modex[i].mask2.mask2 & 0x3u<<j*4) {
                    itpis[i*8+j+MAX_DBBC3_BBC/2+MAX_DBBC3_BBC]=1;
                }
            }
    }
}

