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
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet_r2dbe.h"

extern struct fscom *shm_addr;

void calc_pc( r2dbe_multicast_t *t, struct rdbe_tsys_cycle *cycle)
{
    int i;
    double x[4096],y[4096],amp[4096],phs[4096];
    double xt,yt, theta, cost,sint;
    for (i=0;i<4096;i++) {
      theta=-2*M_PI*t->pcal_freq*(i%8)/4096e6;
      cost=cos(theta);
      sint=sin(theta);
      x[i]=t->pcal_cos[i]*cost-t->pcal_sin[i]*sint;
      y[i]=t->pcal_sin[i]*cost+t->pcal_cos[i]*sint;
    }
    FFT(1,12,&x,&y);
    for (i=0;i<4096;i++) {
	    amp[i]=1e-7*sqrt(pow(x[i],2.0)+pow(y[i],2.0));
      phs[i]=atan2(y[i],x[i])*180/M_PI;
    }
#ifdef WEH
    i=590;
        printf(" ifx %d i %d pcal_sin %d pcal_cos %d amp %g phs %g\n",
            t->pcal_ifx,i,t->pcal_sin[i],t->pcal_cos[i],amp[i],phs[i]);
#endif
    cycle->pcaloff=2600000;
//    int ibin=fmod(cycle->pcaloff+590*1e6+16e6/32e6+1e-12,(double) MAX_R2DBE_CH);
    double tpi_on,tpi_off;
    if(t->pcal_ifx==0) {
      tpi_on=t->tsys0_on[17];
      tpi_off=t->tsys0_off[17];
    } else {
      tpi_on=t->tsys1_on[17];
      tpi_off=t->tsys1_off[17];
    }
    int itone=545;
    amp[545]*=1.25e2/sqrt(tpi_on+tpi_off);
    cycle->pcal_amp[30]=amp[545];
    cycle->pcal_phase[30]=phs[545];
    cycle->pcal_ifx=t->pcal_ifx;
#ifdef WEH
    printf(" pcal_ifx %d\n",t->pcal_ifx);
    for (i=0;i<4096;i++) {
        printf(" i %d pcal_sin %d pcal_cos %d amp %g phs %g\n",
            i,t->pcal_sin[i],t->pcal_cos[i],amp[i],phs[i]);
    }
    fi
#endif
}
