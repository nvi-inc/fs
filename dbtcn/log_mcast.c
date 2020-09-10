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

static void tp_cat(char buf[],int tp)
{
    int2str(buf,tp,-5,0);
    strcat(buf,",");
}

static void ts_cat(char buf[],double ts)
{
    dble2str(buf,ts,-4,1);
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

void log_mcast(dbbc3_ddc_multicast_t *t)
{
    int i,j;

/*
    for (i=0;i<8;i++) {
        printf(" i %d freq %d bw %d usb: on %d  off %d, lsb: on %d off %d\n",
                i+1,
                t->bbc[i].frequency,
                t->bbc[i].bandwidth,
                t->bbc[i].total_power_usb_cal_on,
                t->bbc[i].total_power_usb_cal_off,
                t->bbc[i].total_power_lsb_cal_on,
                t->bbc[i].total_power_lsb_cal_off);
    }

    return;
*/
    double on, off;
    char *start;
    int len;
    char buf[256] = "";
    int cont_cal=shm_addr->dbbc3_cont_cal.mode == 1;
    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
        for (j=0;j<shm_addr->dbbc3_ddc_bbcs_per_if;j++) {

            int ibbc = (j/9)*64+i*8+j;

            if(cont_cal)
                log_out(buf, "tpcont/");
            else
                log_out(buf, "tpi/");

            start=buf+strlen(buf);
            len=sizeof(buf)-strlen(buf);
            snprintf(start,len," %03dl,",ibbc+1);

            on =t->bbc[ibbc].total_power_lsb_cal_on;
            off=t->bbc[ibbc].total_power_lsb_cal_off;
            if(shm_addr->dbbc3_ddc_v<125) {
                on =t->bbc[ibbc].total_power_lsb_cal_off;
                off=t->bbc[ibbc].total_power_lsb_cal_on;
            }
            tp_cat(buf,on);
            if(cont_cal)
                tp_cat(buf,off);

            if(cont_cal)
                log_out(buf, "tpcont/");
            else
                log_out(buf, "tpi/");

            start=buf+strlen(buf);
            len=sizeof(buf)-strlen(buf);
            snprintf(start,len," %03du,",ibbc+1);

            on =t->bbc[ibbc].total_power_usb_cal_on;
            off=t->bbc[ibbc].total_power_usb_cal_off;
            if(shm_addr->dbbc3_ddc_v<125) {
                on =t->bbc[ibbc].total_power_usb_cal_off;
                off=t->bbc[ibbc].total_power_usb_cal_on;
            }
            tp_cat(buf,on);
            if(cont_cal)
                tp_cat(buf,off);
        }
        log_out(buf, "");
    }
    if(cont_cal) {
        double freq, on, off, diff, tsys;
        float fwhm, tcal, dpfu, gain;
        char *start;
        int len;
        for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
            for (j=0;j<shm_addr->dbbc3_ddc_bbcs_per_if;j++) {

                int ibbc = (j/9)*64+i*8+j;

	            int ifchain=shm_addr->dbbc3_bbcnn[ibbc].source;
                if(ifchain < 0 || ifchain >= MAX_LO ||
                        shm_addr->lo.lo[ifchain]<0.0)
                    continue;

	            int ibw=shm_addr->dbbc3_bbcnn[ibbc].bw;
                if(ibw<0 || ibw >= NBW_KEY)
                    continue;

                freq=shm_addr->dbbc3_bbcnn[ibbc].freq*1e-6-bw_key[ibw]*0.5;
                if(shm_addr->lo.sideband[ifchain]==2) // LSB first LO
                    freq=shm_addr->lo.lo[ifchain]-freq;
                else if(shm_addr->lo.sideband[ifchain]==1) // USB first LO
                    freq=shm_addr->lo.lo[ifchain]+freq;
                else
                    goto usb;

                get_gain_par(ifchain+1,freq,&fwhm,&dpfu,NULL,&tcal);

                on =t->bbc[ibbc].total_power_lsb_cal_on;
                off=t->bbc[ibbc].total_power_lsb_cal_off;
                if(shm_addr->dbbc3_ddc_v<125) {
                    on =t->bbc[ibbc].total_power_lsb_cal_off;
                    off=t->bbc[ibbc].total_power_lsb_cal_on;
                }
                diff=on-off;

                if (tcal <=0.0)
                    tsys=-9e12;
                else if(diff <= 0.5)  /* no divide by zero or negative values */
                    tsys=-9e6;
                else {
                    tsys= (tcal/diff)*0.5*(on+off);
                }

                log_out(buf, "tsys/");
                start=buf+strlen(buf);
                len=sizeof(buf)-strlen(buf);
                snprintf(start,len," %03dl,",ibbc+1);
                ts_cat(buf,tsys);

usb:
                freq=shm_addr->dbbc3_bbcnn[ibbc].freq*1e-6+bw_key[ibw]*0.5;
                if(shm_addr->lo.sideband[ifchain]==2) // LSB first LO
                    freq=shm_addr->lo.lo[ifchain]-freq;
                else if(shm_addr->lo.sideband[ifchain]==1) // USB first LO
                    freq=shm_addr->lo.lo[ifchain]+freq;
                else
                    continue;

                get_gain_par(ifchain+1,freq,&fwhm,&dpfu,NULL,&tcal);

                on =t->bbc[ibbc].total_power_usb_cal_on;
                off=t->bbc[ibbc].total_power_usb_cal_off;
                if(shm_addr->dbbc3_ddc_v<125) {
                    on =t->bbc[ibbc].total_power_usb_cal_off;
                    off=t->bbc[ibbc].total_power_usb_cal_on;
                }
                diff=on-off;

                if (tcal <=0.0)
                    tsys=-9e12;
                else if(diff <= 0.5)  /* no divide by zero or negative values */
                    tsys=-9e6;
                else {
                    tsys= (tcal/diff)*0.5*(on+off);
                }

                log_out(buf, "tsys/");
                start=buf+strlen(buf);
                len=sizeof(buf)-strlen(buf);
                snprintf(start,len," %03du,",ibbc+1);
                ts_cat(buf,tsys);

            }
            log_out(buf, "");
        }
    }
}
