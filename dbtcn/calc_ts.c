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

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

static float bw_key[ ]={0,2,4,8,16,32,64,128};
#define NBW_KEY sizeof(bw_key)/sizeof( float)

void calc_ts( dbbc3_ddc_multicast_t *t, struct dbbc3_tsys_cycle *cycle,
        int cont_cal)
{
    unsigned int on, off;
    int diff;
    double freq;
    float fwhm, tcal, dpfu, gain, tsys;
    int j, k;

    /* special tsys values:
       -9e20 not set, from clib/cshm_init.c
       -9e18 BBC not setup
       -9e16 LO not setup
       -9e14 tcal < 0
       -9e12 no continuous cal
       -9e10 overflow (except for IFs)
       -9e9  on and off are zero
       -9e8  off is zero
       -9e7  on  is zero
       -9e6  infinite
       -9e4  too negative
     */

    for (k=0;k<MAX_DBBC3_BBC;k++) {
        cycle->bbc[k].tsys_lsb=-9e18;
        cycle->bbc[k].tsys_usb=-9e18;
    }

    for (k=0;k<MAX_DBBC3_BBC;k++) {

        int ibw=shm_addr->dbbc3_bbcnn[k].bw;
        if(ibw<0 || ibw >= NBW_KEY)
            continue;

        int ifchain=shm_addr->dbbc3_bbcnn[k].source;
        if(ifchain < 0 || MAX_LO <= ifchain)
            continue;

        cycle->bbc[k].tsys_lsb=-9e16;
        cycle->bbc[k].tsys_usb=-9e16;

        if(shm_addr->lo.lo[ifchain]<0.0)
            continue;

        if(shm_addr->lo.pol[ifchain]!=1 &&
                shm_addr->lo.pol[ifchain]!=2 )
            continue;

        if(shm_addr->lo.sideband[ifchain]!=1 &&
                shm_addr->lo.sideband[ifchain]!=2 )
            continue;

        if(shm_addr->dbbc3_bbcnn[k].freq == UINT_MAX)
            continue;

        freq=shm_addr->dbbc3_bbcnn[k].freq*1e-6 - bw_key[ibw]*0.5;
        if(shm_addr->lo.sideband[ifchain]==2) // LSB first LO
            freq=shm_addr->lo.lo[ifchain] - freq;
        else if(shm_addr->lo.sideband[ifchain]==1) // USB first LO
            freq=shm_addr->lo.lo[ifchain] + freq;

        get_gain_par(ifchain+1,freq,&fwhm,&dpfu,NULL,&tcal);

        on =t->bbc[k].total_power_lsb_cal_on;
        off=t->bbc[k].total_power_lsb_cal_off;

        diff=on-off;

        if (tcal <=0.0)
            tsys=-9e14;
        else if (!cont_cal) {
            tsys=shm_addr->systmp[k];
            if(tsys==0.0)
              tsys=-9e12;
            else if(tsys <0.0)
              tsys=9e10; /* so we get $$$$$ on display */
        } else if(on >= 65535 || off >= 65535) /* no overflows */
            tsys=-9e10;
        else if(on==0 && off == 0) /* on and off are zero */
            tsys=-9e9;
        else if(off == 0) /* off is zero */
            tsys=-9e8;
        else if(on == 0) /* on is zero */
            tsys=-9e7;
        else if(diff == 0) /* divide by zero */
            tsys=-9e6;
        else if((tcal/diff)*0.5*(on+off)<=-999.5) /* too negative */
            tsys=-9e4;
        else
            tsys= (tcal/diff)*0.5*(on+off);

        cycle->bbc[k].tsys_lsb=tsys;

        freq=shm_addr->dbbc3_bbcnn[k].freq*1e-6 + bw_key[ibw]*0.5;
        if(shm_addr->lo.sideband[ifchain]==2) // LSB first LO
            freq=shm_addr->lo.lo[ifchain] - freq;
        else if(shm_addr->lo.sideband[ifchain]==1) // USB first LO
            freq=shm_addr->lo.lo[ifchain] + freq;

        get_gain_par(ifchain+1,freq,&fwhm,&dpfu,NULL,&tcal);

        on =t->bbc[k].total_power_usb_cal_on;
        off=t->bbc[k].total_power_usb_cal_off;

        diff=on-off;

        if (tcal <=0.0)
            tsys=-9e14;
        else if (!cont_cal) {
            tsys=shm_addr->systmp[k+MAX_DBBC3_BBC];
            if(tsys==0.0)
              tsys=-9e12;
            else if(tsys <0.0)
              tsys=9e10; /* so we get $$$$$ on display */
        } else if(on >= 65535 || off >= 65535) /* no overflows */
            tsys=-9e10;
        else if(on==0 && off == 0) /* on and off are zero */
            tsys=-9e9;
        else if(off == 0) /* off is zero */
            tsys=-9e8;
        else if(on == 0) /* on is zero */
            tsys=-9e7;
        else if(diff == 0) /* divide by zero */
            tsys=-9e6;
        else if((tcal/diff)*0.5*(on+off)<=-999.5) /* too negative */
            tsys=-9e4;
        else
            tsys= (tcal/diff)*0.5*(on+off);

        cycle->bbc[k].tsys_usb=tsys;
    }

    for (j=0;j<MAX_DBBC3_IF;j++) {
        cycle->ifc[j].tsys=-9e16;

        if (shm_addr->lo.lo[j]<0.0)
            continue;

        if(shm_addr->lo.pol[j]!=1 &&
                shm_addr->lo.pol[j]!=2 )
            continue;

        freq=2048.0;
        if(shm_addr->lo.sideband[j]==2) // LSB first LO
            freq=shm_addr->lo.lo[j]-freq;
        else if(shm_addr->lo.sideband[j]==1) // USB first LO
            freq=shm_addr->lo.lo[j]+freq;
        else
            continue;

        get_gain_par(j+1,freq,&fwhm,&dpfu,NULL,&tcal);

        on = t->core3h[j].total_power_cal_on;
        off= t->core3h[j].total_power_cal_off;

        diff=on-off;

        if (tcal <=0.0)
            tsys=-9e14;
        else if (!cont_cal) {
            tsys=shm_addr->systmp[j+2*MAX_DBBC3_BBC];
            if(tsys==0.0)
              tsys=-9e12;
            else if(tsys <0.0)
              tsys=9e10; /* so we get $$$$$ on display */
      /* no information on what an overflow is */
        else if(on==0 && off == 0) /* on and off are zero */
            tsys=-9e9;
        } else if(off == 0) /* off is zero */
            tsys=-9e8;
        else if(on == 0) /* on is zero */
            tsys=-9e7;
        else if(diff == 0) /* divide by zero */
            tsys=-9e6;
        else if((tcal/diff)*0.5*(on+off)<=-999.5) /* too negative */
            tsys=-9e4;
        else
            tsys= (tcal/diff)*0.5*(on+off);

        cycle->ifc[j].tsys=tsys;
    }
}
