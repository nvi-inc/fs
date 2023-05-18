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
#include <limits.h>
#include <sys/types.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

static struct {
    struct {
        double tsys;
        unsigned count;
    } ifc[MAX_DBBC3_IF];
    struct {
          double tsys_lsb;
          unsigned count_lsb;
          double tsys_usb;
          unsigned count_usb;
      } bbc[MAX_DBBC3_BBC];
} saved;

void smooth_ts( struct dbbc3_tsys_cycle *cycle, int reset, int samples,
    int filter, float if_param[MAX_DBBC3_IF])
{
    int j, k;

    if(reset||0>=samples) {
        for (j=0;j<MAX_DBBC3_IF;j++) {
            saved.ifc[j].tsys=cycle->ifc[j].tsys;
            saved.ifc[j].count=0;
            if(0.0<saved.ifc[j].tsys)
                saved.ifc[j].count=1;
            cycle->ifc[j].clipped=0;
        }
        for (k=0;k<MAX_DBBC3_BBC;k++) {
            saved.bbc[k].tsys_lsb=cycle->bbc[k].tsys_lsb;
            saved.bbc[k].count_lsb=0;
            if(0.0<saved.bbc[k].tsys_lsb)
                saved.bbc[k].count_lsb=1;
            cycle->bbc[k].clipped_lsb=0;

            saved.bbc[k].tsys_usb=cycle->bbc[k].tsys_usb;
            saved.bbc[k].count_usb=0;
            if(0.0<saved.bbc[k].tsys_usb)
                saved.bbc[k].count_usb=1;
            cycle->bbc[k].clipped_usb=0;
        }
        return;
    }

    /* exponential smoothing with time constant 'samples' */

    double alpha=1.0-exp(-1.0/samples);

    for (j=0;j<MAX_DBBC3_IF;j++) {
        if(cycle->ifc[j].tsys<0.0)
            continue;
        if(0.0<=saved.ifc[j].tsys) {
            if(saved.ifc[j].count < samples || 0==filter ||
              1==filter && 100*fabs(cycle->ifc[j].tsys-saved.ifc[j].tsys)/saved.ifc[j].tsys < if_param[j]) {

                cycle->ifc[j].tsys=alpha*cycle->ifc[j].tsys + (1.0-alpha)*saved.ifc[j].tsys;
                cycle->ifc[j].clipped=0;

                saved.ifc[j].tsys=cycle->ifc[j].tsys;
                saved.ifc[j].count++;
            } else if (1==filter) {
                cycle->ifc[j].tsys=saved.ifc[j].tsys;
                cycle->ifc[j].clipped++;
            }
        } else {
            saved.ifc[j].tsys=cycle->ifc[j].tsys;
            saved.ifc[j].count=1;
            cycle->ifc[j].clipped=0;
        }
    }

    for (k=0;k<MAX_DBBC3_BBC;k++) {
        float param1 = if_param[k%64/8];
        if(cycle->bbc[k].tsys_lsb<0.0)
            continue;
        if(0.0<=saved.bbc[k].tsys_lsb) {
            if(saved.bbc[k].count_lsb < samples || 0==filter ||
              1==filter && 100*fabs(cycle->bbc[k].tsys_lsb-saved.bbc[k].tsys_lsb)/saved.bbc[k].tsys_lsb < param1) {

                cycle->bbc[k].tsys_lsb=alpha*cycle->bbc[k].tsys_lsb + (1.0-alpha)*saved.bbc[k].tsys_lsb;
                cycle->bbc[k].clipped_lsb=0;

                saved.bbc[k].tsys_lsb=cycle->bbc[k].tsys_lsb;
                saved.bbc[k].count_lsb++;
            } else if (1==filter) {
                cycle->bbc[k].tsys_lsb=saved.bbc[k].tsys_lsb;
                cycle->bbc[k].clipped_lsb++;
            }
        } else {
            saved.bbc[k].tsys_lsb=cycle->bbc[k].tsys_lsb;
            saved.bbc[k].count_lsb=1;
            cycle->bbc[k].clipped_lsb=0;
        }
    }

    for (k=0;k<MAX_DBBC3_BBC;k++) {
        float param1 = if_param[k%64/8];
        if(cycle->bbc[k].tsys_usb<0.0)
            continue;
        if(0.0<saved.bbc[k].tsys_usb && 0.0<cycle->bbc[k].tsys_usb) {
            if(saved.bbc[k].count_usb < samples || 0==filter ||
              1==filter && 100*fabs(cycle->bbc[k].tsys_usb-saved.bbc[k].tsys_usb)/saved.bbc[k].tsys_usb < param1) {

                cycle->bbc[k].tsys_usb=alpha*cycle->bbc[k].tsys_usb + (1.0-alpha)*saved.bbc[k].tsys_usb;
                cycle->bbc[k].clipped_usb=0;

                saved.bbc[k].tsys_usb=cycle->bbc[k].tsys_usb;
                saved.bbc[k].count_usb++;
            } else if (1==filter) {
                cycle->bbc[k].tsys_usb=saved.bbc[k].tsys_usb;
                cycle->bbc[k].clipped_usb++;
            }
        } else {
            saved.bbc[k].tsys_usb=cycle->bbc[k].tsys_usb;
            saved.bbc[k].count_usb=1;
            cycle->bbc[k].clipped_usb=0;
        }
     }
}
