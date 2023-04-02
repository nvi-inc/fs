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
    } ifc[MAX_DBBC3_IF];
    struct {
          double tsys_lsb;
          double tsys_usb;
      } bbc[MAX_DBBC3_BBC];
} saved;

void smooth_ts( struct dbbc3_tsys_cycle *cycle, int reset, int samples)
{
    int j, k;

    if(reset||0>=samples) {
        for (j=0;j<MAX_DBBC3_IF;j++)
            saved.ifc[j].tsys=cycle->ifc[j].tsys;

        for (k=0;k<MAX_DBBC3_BBC;k++) {
            saved.bbc[k].tsys_lsb=cycle->bbc[k].tsys_lsb;
            saved.bbc[k].tsys_usb=cycle->bbc[k].tsys_usb;
        }
        return;
    }

    /* exponential smoothing with time constant 'samples' */

    double alpha=1.0-exp(-1.0/samples);

    for (j=0;j<MAX_DBBC3_IF;j++) {
        if(0.0<saved.ifc[j].tsys && 0.0<cycle->ifc[j].tsys)
            cycle->ifc[j].tsys=alpha*cycle->ifc[j].tsys
                +(1.0-alpha)*saved.ifc[j].tsys;
        saved.ifc[j].tsys=cycle->ifc[j].tsys;
    }

    for (k=0;k<MAX_DBBC3_BBC;k++) {
        if(0.0<saved.bbc[k].tsys_lsb && 0.0<cycle->bbc[k].tsys_lsb)
            cycle->bbc[k].tsys_lsb=alpha*cycle->bbc[k].tsys_lsb
                +(1.0-alpha)*saved.bbc[k].tsys_lsb;
        saved.bbc[k].tsys_lsb=cycle->bbc[k].tsys_lsb;

        if(0.0<saved.bbc[k].tsys_usb && 0.0<cycle->bbc[k].tsys_usb)
            cycle->bbc[k].tsys_usb=alpha*cycle->bbc[k].tsys_usb
                +(1.0-alpha)*saved.bbc[k].tsys_usb;
        saved.bbc[k].tsys_usb=cycle->bbc[k].tsys_usb;
     }
}
