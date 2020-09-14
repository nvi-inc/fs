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

#include <stdio.h>
#include <string.h>

#include "../include/clib.h"
#include "../include/poclb.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

static float bw_key[ ]={2,4,8,16,32,64,128};
#define NBW_KEY sizeof(bw_key)/sizeof( float)

static void if_cat(char buf[],int tp)
{
    int2str(buf,tp,-8,0);
    strcat(buf,",");
}

static void bb_cat(char buf[],int tp)
{
    int2str(buf,tp,-5,0);
    strcat(buf,",");
}

static void ts_cat(char buf[],double ts)
{
    dble2str(buf,ts,-4,1);
    strcat(buf,",");
}
static void dt_cat(char buf[],char dt[4])
{
    strcat(buf," ");

    int len=strlen(buf);
    strncat(buf,dt,4);
    buf[len+4]=0;
    strcat(buf,",");
}

static void log_out(char buf[],char *string)
{
    static int slen = 0;

    if((strlen(buf) >  100 || strlen(string)==0) && strlen(buf) > slen) {
        buf[strlen(buf)-1]=0;
        logit(buf,0,NULL);
        buf[0]=0;
    }
    if(buf[0]==0 && strlen(string) !=0) {
        strcpy(buf,string);
        slen=strlen(buf);
    }
}

static void log_tp( dbbc3_ddc_multicast_t *t, char buf[], int cont_cal)
{
    int on, off;

    for (int j=0;j<MAX_DBBC3_IF+1;j++) {
        for (int k=0;k<MAX_DBBC3_BBC;k++) {
            if (shm_addr->tpicd.itpis[k] && shm_addr->tpicd.ifc[k] == j) {
                if(cont_cal)
                    log_out(buf, "tpcont/");
                else
                    log_out(buf, "tpi/");

                dt_cat(buf,shm_addr->tpicd.lwhat[k]);
                on =t->bbc[k].total_power_lsb_cal_on;
                off=t->bbc[k].total_power_lsb_cal_off;
                if(shm_addr->dbbc3_ddcu_v<125 && cont_cal) {
                    on =t->bbc[k].total_power_lsb_cal_off;
                    off=t->bbc[k].total_power_lsb_cal_on;
                }
                bb_cat(buf,on);
                if(cont_cal)
                    bb_cat(buf,off);
            }
            if (shm_addr->tpicd.itpis[k+MAX_DBBC3_BBC] && shm_addr->tpicd.ifc[k+MAX_DBBC3_BBC] == j) {
                if(cont_cal)
                    log_out(buf, "tpcont/");
                else
                    log_out(buf, "tpi/");

                dt_cat(buf,shm_addr->tpicd.lwhat[k+MAX_DBBC3_BBC]);
                on =t->bbc[k].total_power_usb_cal_on;
                off=t->bbc[k].total_power_usb_cal_off;
                if(shm_addr->dbbc3_ddcu_v<125 && cont_cal) {
                    on =t->bbc[k].total_power_usb_cal_off;
                    off=t->bbc[k].total_power_usb_cal_on;
                }
                bb_cat(buf,on);
                if(cont_cal)
                    bb_cat(buf,off);
            }
        }
        if (j!= 0 && shm_addr->tpicd.itpis[j-1+MAX_DBBC3_BBC*2]) {
            if(cont_cal)
                log_out(buf, "tpcont/");
            else
                log_out(buf, "tpi/");

            dt_cat(buf,shm_addr->tpicd.lwhat[j-1+MAX_DBBC3_BBC*2]);
            on = t->core3h[j-1].total_power_cal_on;
            off= t->core3h[j-1].total_power_cal_off;
            if(shm_addr->dbbc3_ddcu_v<125 && cont_cal) {
                on = t->core3h[j-1].total_power_cal_off;
                off= t->core3h[j-1].total_power_cal_on;
            }
            if_cat(buf,on);
            if(cont_cal)
                if_cat(buf,off);
        }
        log_out(buf, "");
    }
}
static void log_ts( dbbc3_ddc_multicast_t *t, char buf[])
{
    int on, off, diff;
    double freq, tsys;
    float fwhm, tcal, dpfu, gain;

    for (int j=0;j<MAX_DBBC3_IF+1;j++) {
        for (int k=0;k<MAX_DBBC3_BBC;k++) {

            int ifchain=shm_addr->dbbc3_bbcnn[k].source;
            if(ifchain < 0 || ifchain >= MAX_LO ||
                    shm_addr->lo.lo[ifchain]<0.0)
                continue;

            int ibw=shm_addr->dbbc3_bbcnn[k].bw;
            if(ibw<0 || ibw >= NBW_KEY)
                continue;

            if(shm_addr->lo.sideband[ifchain]!=1 &&
                    shm_addr->lo.sideband[ifchain]!=2 )
                continue;

            if (shm_addr->tpicd.itpis[k] && shm_addr->tpicd.ifc[k] == j) {

                freq=shm_addr->dbbc3_bbcnn[k].freq*1e-6 - bw_key[ibw]*0.5;
                if(shm_addr->lo.sideband[ifchain]==2) // LSB first LO
                    freq=shm_addr->lo.lo[ifchain] - freq;
                else // USB first LO
                    freq=shm_addr->lo.lo[ifchain] + freq;

                get_gain_par(ifchain+1,freq,&fwhm,&dpfu,NULL,&tcal);

                on =t->bbc[k].total_power_lsb_cal_on;
                off=t->bbc[k].total_power_lsb_cal_off;
                if(shm_addr->dbbc3_ddcu_v<125) {
                    on =t->bbc[k].total_power_lsb_cal_off;
                    off=t->bbc[k].total_power_lsb_cal_on;
                }
                diff=on-off;

                if (tcal <=0.0)
                    tsys=-9e12;
                else if(diff <= 0 || on >= 65535 || off >= 65535)
                    /* no divide by zero, negative values, or overflows */
                    tsys=-9e6;
                else {
                    tsys= (tcal/diff)*0.5*(on+off);
                }

                log_out(buf, "tsys/");
                dt_cat(buf,shm_addr->tpicd.lwhat[k]);
                ts_cat(buf,tsys);
            }
            if (shm_addr->tpicd.itpis[k+MAX_DBBC3_BBC] && shm_addr->tpicd.ifc[k+MAX_DBBC3_BBC] == j) {

                freq=shm_addr->dbbc3_bbcnn[k].freq*1e-6 + bw_key[ibw]*0.5;
                if(shm_addr->lo.sideband[ifchain]==2) // LSB first LO
                    freq=shm_addr->lo.lo[ifchain] - freq;
                else // USB first LO
                    freq=shm_addr->lo.lo[ifchain] + freq;

                get_gain_par(ifchain+1,freq,&fwhm,&dpfu,NULL,&tcal);

                on =t->bbc[k].total_power_usb_cal_on;
                off=t->bbc[k].total_power_usb_cal_off;
                if(shm_addr->dbbc3_ddcu_v<125) {
                    on =t->bbc[k].total_power_usb_cal_off;
                    off=t->bbc[k].total_power_usb_cal_on;
                }
                diff=on-off;

                if (tcal <=0.0)
                    tsys=-9e12;
                else if(diff <= 0 || on >= 65535 || off >= 65535)
                    /* no divide by zero, negative values, or overflows */
                    tsys=-9e6;
                else {
                    tsys= (tcal/diff)*0.5*(on+off);
                }

                log_out(buf, "tsys/");
                dt_cat(buf,shm_addr->tpicd.lwhat[k+MAX_DBBC3_BBC]);
                ts_cat(buf,tsys);

            }
        }
        if (j!= 0 && shm_addr->tpicd.itpis[j-1+MAX_DBBC3_BBC*2]) {

            freq=2048.0;
            if(shm_addr->lo.sideband[j-1]==2) // LSB first LO
                freq=shm_addr->lo.lo[j-1]-freq;
            else if(shm_addr->lo.sideband[j-1]==1) // USB first LO
                freq=shm_addr->lo.lo[j-1]+freq;
            else
                continue;

            get_gain_par(j,freq,&fwhm,&dpfu,NULL,&tcal);

            on = t->core3h[j-1].total_power_cal_on;
            off= t->core3h[j-1].total_power_cal_off;
            if(shm_addr->dbbc3_ddcu_v<125) {
                on = t->core3h[j-1].total_power_cal_off;
                off= t->core3h[j-1].total_power_cal_on;
            }
            diff=on-off;

            if (tcal <=0.0)
                tsys=-9e12;
            else if(diff < 0)
                /* no divide by zero or negative values */
                tsys=-9e6;
            else {
                tsys= (tcal/diff)*0.5*(on+off);
            }

            log_out(buf, "tsys/");
            dt_cat(buf,shm_addr->tpicd.lwhat[j-1+MAX_DBBC3_BBC*2]);
            ts_cat(buf,tsys);
        }
        log_out(buf, "");
    }
}

void log_mcast(dbbc3_ddc_multicast_t *t)
{
    char buf[256] = "";
    int cont_cal=shm_addr->dbbc3_cont_cal.mode == 1;

    log_tp( t, buf, cont_cal);

    if(cont_cal)
        log_ts( t, buf);

}
