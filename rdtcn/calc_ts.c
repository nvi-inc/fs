/*
 * Copyright (c) 2020-2023 NVI, Inc.
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

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet_r2dbe.h"

extern struct fscom *shm_addr;

void calc_ts( r2dbe_multicast_t *t)
{
    unsigned int on, off;
    int i;
    int diff;
    double tsys;
    double tcal=1.0;

    for (i=0;i<MAX_R2DBE_CH;i++) {
        on =t->tsys0_on[i];
        off=t->tsys0_off[i];

        diff=on-off;
        tsys= (tcal/diff)*0.5*(on+off);

#ifdef WEH
        printf(" if0 channel %d on %8u off %8u tsys %f\n",
            i,on,off,tsys);
#endif
    }

    for (i=0;i<MAX_R2DBE_CH;i++) {
        on =t->tsys1_on[i];
        off=t->tsys1_off[i];

        diff=on-off;
        tsys= (tcal/diff)*0.5*(on+off);

#ifdef WEH
        printf(" if1 channel %d on %8u off %8u tsys %f\n",
            i,on,off,tsys);
#endif
    }
}
