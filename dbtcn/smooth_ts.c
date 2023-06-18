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

#define WARN2  5

static struct {
    struct {
        float tsys;
        unsigned count;
    } ifc[MAX_DBBC3_IF];
    struct {
          float tsys_lsb;
          unsigned count_lsb;
          float tsys_usb;
          unsigned count_usb;
      } bbc[MAX_DBBC3_BBC];
} saved, shadow;

static void apply_filter(int filter,int samples,float alpha, float param,
    float *tsys,float *saved,unsigned *count,unsigned *clipped,
    float *shadow_saved, unsigned *shadow_count)
{
    if(*clipped == UINT_MAX)
      *clipped=0;

    if(*tsys<=-999.5 || *tsys >=999.95) {
        if(1 != filter && -1e4<=*saved && *count >= samples && -1e6 < *tsys)
            ++*clipped;
        return;
    } else if(-1e4<=*saved && fabs(*saved) >= 0.05) {
        float orig_tsys=*tsys;
        if(*count < samples || 0==filter || 1==filter && param >= 0.0 && 100.0*fabs((*tsys-*saved)/(*saved)) < param) {
            *tsys=alpha* *tsys + (1.0-alpha)* *saved;
            *clipped=0;

            *saved=*tsys;
            ++*count;
        } else if (1==filter && param >= 0.0) {
            *tsys=*saved;
            ++*clipped;
        }
        if(1==filter && param >=0.0) {
//          printf(" before: count %u shadow_count %u shadow_saved %f orig_tsys %f saved %f\n",
//                  *count,*shadow_count,*shadow_saved,orig_tsys,*saved);
          if(*shadow_count > 0)
              *shadow_saved=alpha* orig_tsys + (1.0-alpha)* *shadow_saved;
          else
              *shadow_saved=orig_tsys;
          ++*shadow_count;
          if(*shadow_count >=samples ) {
            if(100.0*fabs((*shadow_saved-*saved)/(*saved)) >= param && *clipped > WARN2+1) {
              *tsys=*shadow_saved;
              *clipped=UINT_MAX;
              *saved=*shadow_saved;
              *count=*shadow_count;
            }
            *shadow_count=0;
          }
//          printf(" after: count %u shadow_count %u shadow_saved %f orig_tsys %f saved %f\n",
//                  *count,*shadow_count,*shadow_saved,orig_tsys,*saved);
        }
    } else {
        *saved=*tsys;
        *count=1;
        *clipped=0;
        *shadow_saved=*saved;
        *shadow_count=*count;
    }
}

void smooth_ts( struct dbbc3_tsys_cycle *cycle, int reset, int samples,
    int filter, float if_param[MAX_DBBC3_IF])
{
    int j, k;

    if(reset||0>=samples) {
        for (j=0;j<MAX_DBBC3_IF;j++) {
            if(-999.5 < cycle->ifc[j].tsys && cycle->ifc[j].tsys < 999.95) {
                saved.ifc[j].tsys=cycle->ifc[j].tsys;
                saved.ifc[j].count=1;
            } else {
                saved.ifc[j].tsys=-9e20;
                saved.ifc[j].count=0;
            }
            cycle->ifc[j].clipped=0;

            shadow.ifc[j].tsys=saved.ifc[j].tsys;
            shadow.ifc[j].count=saved.ifc[j].count;
        }
        for (k=0;k<MAX_DBBC3_BBC;k++) {
            if(-999.5 < cycle->bbc[k].tsys_lsb && cycle->bbc[k].tsys_lsb < 999.95) {
                saved.bbc[k].tsys_lsb=cycle->bbc[k].tsys_lsb;
                saved.bbc[k].count_lsb=1;
            } else {
                saved.bbc[k].tsys_lsb=-9e20;
                saved.bbc[k].count_lsb=0;
            }
            cycle->bbc[k].clipped_lsb=0;

            if(-999.5 < cycle->bbc[k].tsys_usb && cycle->bbc[k].tsys_usb < 999.95) {
                saved.bbc[k].tsys_usb=cycle->bbc[k].tsys_usb;
                saved.bbc[k].count_usb=1;
            } else {
                saved.bbc[k].tsys_usb=-9e20;
                saved.bbc[k].count_usb=0;
            }
            cycle->bbc[k].clipped_usb=0;

            shadow.bbc[k].tsys_lsb=saved.bbc[k].tsys_lsb;
            shadow.bbc[k].count_lsb=saved.bbc[k].count_lsb;
            shadow.bbc[k].tsys_usb=saved.bbc[k].tsys_usb;
            shadow.bbc[k].count_usb=saved.bbc[k].count_lsb;
        }
        return;
    }

    /* exponential smoothing with time constant 'samples' */

    float alpha=1.0-exp(-1.0/samples);

    for (j=0;j<MAX_DBBC3_IF;j++)
        apply_filter(filter,samples,alpha,if_param[j],
                     &cycle->ifc[j].tsys,&saved.ifc[j].tsys,
                     &saved.ifc[j].count,&cycle->ifc[j].clipped,
                     &shadow.ifc[j].tsys,&shadow.ifc[j].count);

    for (k=0;k<MAX_DBBC3_BBC;k++) {
        float param = if_param[k%64/8];

        apply_filter(filter,samples,alpha,param,
                     &cycle->bbc[k].tsys_lsb,&saved.bbc[k].tsys_lsb,
                     &saved.bbc[k].count_lsb,&cycle->bbc[k].clipped_lsb,
                     &shadow.bbc[k].tsys_lsb,&shadow.bbc[k].count_lsb);

        apply_filter(filter,samples,alpha,param,
                     &cycle->bbc[k].tsys_usb,&saved.bbc[k].tsys_usb,
                     &saved.bbc[k].count_usb,&cycle->bbc[k].clipped_usb,
                     &shadow.bbc[k].tsys_usb,&shadow.bbc[k].count_usb);
     }
}
