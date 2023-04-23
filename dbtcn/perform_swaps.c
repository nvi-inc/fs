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

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

char *getenv_DBBC3( char *env, int *actual, int *nominal, int *error, int options);

void perform_swaps( dbbc3_ddc_multicast_t *t)
{
    static int ul = -1;
    static int bbc_onoff = -1;
    static int core3h_onoff0 = -1;
    static int core3h_onoff2 = -1;
    static int time_add = -1;
    static int time_adder = 0;

    char *ptr;
    int k;
    unsigned int temp_uint;

    if(0>ul) {
        int actual, error;
        ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_BBC_TPI_USB_LSB_SWAP",&actual,NULL,&error,1);
        if(0==error)
            ul=actual;
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
        int actual, error;
        ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_BBC_ON_OFF_SWAP",&actual,NULL,&error,1);
        if(0==error)
            bbc_onoff=actual;
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
            int actual, error;
            ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_CORE3H_POLARITY0_ON_OFF_SWAP",&actual,NULL,&error,1);
            if(0==error)
                core3h_onoff0=actual;
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
            int actual, error;
            ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_CORE3H_POLARITY2_ON_OFF_SWAP",&actual,NULL,&error,1);
            if(0==error)
                core3h_onoff2=actual;
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
    if(0>time_add) {
        int actual, error;
        ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_CORE3H_TIME_ADD_SECONDS",&actual,NULL,&error,1);
        if(0==error) {
	    time_adder=actual;
	    time_add=1;
        } else
	    time_add=0;
    }
    if(time_add)
	for (k=0;k<MAX_DBBC3_IF;k++)
            t->core3h[k].timestamp+=time_adder;
}
