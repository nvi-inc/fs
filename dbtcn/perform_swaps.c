/*
 * Copyright (c) 2023 NVI, Inc.
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

void perform_swaps( dbbc3_ddc_multicast_t *t)
{
    static int ul = -1;
    static int bbc_onoff = -1;
    static int core3h_onoff0 = -1;
    static int core3h_onoff2 = -1;
    char *ptr;
    int k;
    unsigned int temp_uint;

    if(0>ul) {
        ptr=getenv("FS_DBBC3_MULTICAST_BBC_TPI_USB_LSB_SWAP");
        if(NULL!=ptr && !strcmp(ptr,"1"))
            ul=1;
        else
            ul=0;
    }
    if (ul)
        for (k=0;k<MAX_DBBC3_BBC;k++) {

            temp_uint =t->bbc[k].total_power_lsb_cal_off;
            t->bbc[k].total_power_lsb_cal_off=t->bbc[k].total_power_usb_cal_off;
            t->bbc[k].total_power_usb_cal_off=temp_uint;

            temp_uint =t->bbc[k].total_power_lsb_cal_on;
            t->bbc[k].total_power_lsb_cal_on=t->bbc[k].total_power_usb_cal_on;
            t->bbc[k].total_power_usb_cal_on=temp_uint;
        }

    if(0>bbc_onoff) {
        ptr=getenv("FS_DBBC3_MULTICAST_BBC_ON_OFF_SWAP");
        if(NULL!=ptr && !strcmp(ptr,"1"))
            bbc_onoff=1;
        else
            bbc_onoff=0;
    }
    if(bbc_onoff)
        for (k=0;k<MAX_DBBC3_BBC;k++) {

            temp_uint =t->bbc[k].total_power_lsb_cal_off;
            t->bbc[k].total_power_lsb_cal_off=t->bbc[k].total_power_lsb_cal_on;
            t->bbc[k].total_power_lsb_cal_on =temp_uint;

            temp_uint =t->bbc[k].total_power_usb_cal_off;
            t->bbc[k].total_power_usb_cal_off=t->bbc[k].total_power_usb_cal_on;
            t->bbc[k].total_power_usb_cal_on =temp_uint;

        }
    if(0==shm_addr->dbbc3_cont_cal.polarity/2) {
        if(0>core3h_onoff0) {
            ptr=getenv("FS_DBBC3_MULTICAST_CORE3H_POLARITY0_ON_OFF_SWAP");
            if(NULL!=ptr && !strcmp(ptr,"1"))
                core3h_onoff0=1;
            else
                core3h_onoff0=0;
        }
        if(core3h_onoff0)
            for (k=0;k<MAX_DBBC3_IF;k++) {

                temp_uint =t->core3h[k].total_power_cal_off;
                t->core3h[k].total_power_cal_off=t->core3h[k].total_power_cal_on;
                t->core3h[k].total_power_cal_on=temp_uint;
            }
    } else {
        if(0>core3h_onoff2) {
            ptr=getenv("FS_DBBC3_MULTICAST_CORE3H_POLARITY2_ON_OFF_SWAP");
            if(NULL!=ptr && !strcmp(ptr,"1"))
                core3h_onoff2=1;
            else
                core3h_onoff2=0;
        }
        if(core3h_onoff2)
            for (k=0;k<MAX_DBBC3_IF;k++) {

                temp_uint =t->core3h[k].total_power_cal_off;
                t->core3h[k].total_power_cal_off=t->core3h[k].total_power_cal_on;
                t->core3h[k].total_power_cal_on=temp_uint;
            }
    }
}
