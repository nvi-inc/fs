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

#include "packet.h"
#include "dbtcn.h"

void perform_swaps( dbbc3_ddc_multicast_t *t)
{
    static int ul = -1;
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
}
