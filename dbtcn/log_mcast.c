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

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

static void cattp(char buf[],int tp)
{
    int2str(buf,tp,-5,0);
    strcat(buf,",");
}

static void logtp(char buf[],int force)
{
    static int slen = 0;

    if((strlen(buf) >  100 || force ) && strlen(buf) > slen) {
        buf[strlen(buf)-1]=0;
        logit(buf,0,NULL);
        buf[0]=0;
    }
    if(buf[0]==0 && !force) {
        strcpy(buf,"tpcont/");
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
    char buf[256] = "";
    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
        for (j=0;j<shm_addr->dbbc3_ddc_bbcs_per_if;j++) {

            int ibbc = (j/9)*64+i*8+1+j;

            logtp(buf, FALSE);
            char *start=buf+strlen(buf);
            int len=sizeof(buf)-strlen(buf);
            snprintf(start,len," %03dl,",ibbc);

            cattp(buf,t->bbc[ibbc-1].total_power_lsb_cal_on);
            cattp(buf,t->bbc[ibbc-1].total_power_lsb_cal_off);

            logtp(buf, FALSE);
            start=buf+strlen(buf);
            len=sizeof(buf)-strlen(buf);
            snprintf(start,len," %03du,",ibbc);

            cattp(buf,t->bbc[ibbc-1].total_power_usb_cal_on);
            cattp(buf,t->bbc[ibbc-1].total_power_usb_cal_off);
        }
        logtp(buf, TRUE);
    }
}
