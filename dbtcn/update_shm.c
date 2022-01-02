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

#include <time.h>
#include <stdio.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "ssize_t.h"
#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

void update_shm( dbbc3_ddc_multicast_t *t, struct dbbc3_tsys_cycle *cycle,
        int it[6], int centisec[6])
{
    int i;
    int seconds;

    int v124 =  DBBC3_DDCU == shm_addr->equip.rack_type &&
        shm_addr->dbbc3_ddcu_v<125 ||
        DBBC3_DDCV == shm_addr->equip.rack_type &&
        shm_addr->dbbc3_ddcv_v<125;

    rte2secs(it,&seconds);
    clock_t now=seconds;
    struct tm *ptr=gmtime(&now);
    if(ptr->tm_mon<6)
        ptr->tm_mon=0;
    else
        ptr->tm_mon=6;
    ptr->tm_mday=1;
    ptr->tm_hour=0;
    ptr->tm_min=0;
    ptr->tm_sec=0;
    clock_t epoch=mktime(ptr);

    int	vdif_should=(ptr->tm_year-100)%32;
    vdif_should=vdif_should*2+ptr->tm_mon/6;

    cycle->last=seconds;
    memcpy(cycle->centisec,centisec,sizeof(cycle->centisec));
    cycle->hsecs=it[0];

    for (i=0;i<MAX_DBBC3_IF;i++) {
        cycle->ifc[i].lo=shm_addr->lo.lo[i];
        cycle->ifc[i].sideband=shm_addr->lo.sideband[i];
        cycle->ifc[i].delay=t->core3h[i].pps_delay;
        if(v124)
            cycle->ifc[i].time=seconds;
        else
            cycle->ifc[i].time=t->core3h[i].timestamp+epoch;
        cycle->ifc[i].vdif_epoch=-1;
        cycle->ifc[i].time_error=cycle->ifc[i].time-seconds;
    }

    for (i=0;i<MAX_DBBC3_BBC;i++)
        cycle->bbc[i].freq=shm_addr->dbbc3_bbcnn[i].freq;

    int iping=1-shm_addr->dbbc3_tsys_data.iping;

    if (iping!=0)
        iping = 1;

    memcpy(&shm_addr->dbbc3_tsys_data.data[iping],cycle,
            sizeof(struct dbbc3_tsys_cycle));

    shm_addr->dbbc3_tsys_data.iping=iping;
}
