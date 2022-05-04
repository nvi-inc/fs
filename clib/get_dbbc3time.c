/*
 * Copyright (c) 2021, 2022 NVI, Inc.
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
/* get time information from multicast */

#include <memory.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int get_dbbc3time(centisec,fm_tim,iold)
int centisec[6];
int fm_tim[6];
int *iold;
{
    int it[6],seconds;
    rte_time(it,it+5);
    rte2secs(it,&seconds);

    if(DBBC3_DDCU == shm_addr->equip.rack_type &&
       shm_addr->dbbc3_ddcu_v<125 ||
       DBBC3_DDCV == shm_addr->equip.rack_type &&
       shm_addr->dbbc3_ddcv_v<125)
      return -1;

    int iping=shm_addr->dbbc3_tsys_data.iping;
    /* trap 1 for v124 in case that is loaded despite control files,
       multiple tries will get a better value if not v124 */
    if (1>=shm_addr->dbbc3_tsys_data.data[iping].ifc[shm_addr->dbbc3_iscboard-1].raw_timestamp)
       return -2;

    *iold=seconds-shm_addr->dbbc3_tsys_data.data[iping].last;
    int secs=shm_addr->dbbc3_tsys_data.data[iping].ifc[shm_addr->dbbc3_iscboard-1].time;

    memcpy(centisec,shm_addr->dbbc3_tsys_data.data[iping].centisec,
       6*sizeof(centisec[0]));
    secs2rte(&secs,fm_tim);
    fm_tim[0]=shm_addr->dbbc3_mcdelay;

    return 0;
}
