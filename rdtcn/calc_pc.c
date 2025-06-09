/*
 * Copyright (c) 2025 NVI, Inc.
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

void calc_pc( r2dbe_multicast_t *t, struct r2dbe_tsys_cycle *cycle, int irdbe)
{
  int i;
  double x[4096],y[4096];
  double xt,yt, theta, cost,sint;
  double pcal_offset,pcal_spacing;

  pcal_spacing=-1;
  for (i=0;i<MAX_R2DBE_IF;i++) {
    int ifchain=irdbe*MAX_R2DBE_IF+i+1;
    if(pcal_spacing  < 0.1
        && shm_addr->lo.lo[ifchain-1] >= 0.0
        && shm_addr->lo.spacing[ifchain-1] > 0 ) {
      pcal_spacing=shm_addr->lo.spacing[ifchain-1]*1e6;
    } /* take the first valid value */
  }

  cycle->pcal_ifx=t->pcal_ifx;
  if(shm_addr->rdbe_pc_offset[irdbe+1].offset.state.known &&
      shm_addr->rdbe_pc_offset[irdbe+1].offset.offset >0.0 &&
      pcal_spacing > 0)
    pcal_offset=shm_addr->rdbe_pc_offset[irdbe+1].offset.offset;
  else
    pcal_offset=-1;
  cycle->pcal_offset=pcal_offset;
  cycle->pcal_spacing=pcal_spacing;

  for (i=0;i<4096;i++) {
    theta=-2*M_PI*pcal_offset*(i%8)/4096e6;
    cost=cos(theta);
    sint=sin(theta);
    x[i]=t->pcal_cos[i]*cost-t->pcal_sin[i]*sint;
    y[i]=t->pcal_sin[i]*cost+t->pcal_cos[i]*sint;
  }
  FFT(1,12,&x,&y);
  for (i=0;i<MAX_R2DBE_CH*32;i++) {
    if(shm_addr->rdbe_equip.pcal_amp[0]=='r'||
        shm_addr->rdbe_equip.pcal_amp[0]=='n'||
        shm_addr->rdbe_equip.pcal_amp[0]=='c')
      cycle->pcal_amp[i]=1e-7*sqrt(pow(x[i],2.0)+pow(y[i],2.0));

    if(shm_addr->rdbe_equip.pcal_amp[0]=='n'||
        shm_addr->rdbe_equip.pcal_amp[0]=='c') {
      int ibin; /* find channel of tone, critical cases round up */
      ibin=fmod((pcal_offset+i*1e6+16e6)/32e6+1e-12,(double)MAX_R2DBE_CH);
      /* Brian determined 1.25e-5 empirically, independent of RMS level */
      if(t->pcal_ifx!=1)
        cycle->pcal_amp[i]*=1.25e2/
          sqrt((double) t->tsys0_on[ibin]+(double)t->tsys0_off[ibin]);
      else
        cycle->pcal_amp[i]*=1.25e2/
          sqrt((double) t->tsys1_on[ibin]+(double)t->tsys1_off[ibin]);
    }
    if(shm_addr->rdbe_equip.pcal_amp[0]=='c') {
      float freq;
      /* correct for 32 Mhz channel roll-off so reported value agrees
         with correlator, roll-off from Russ */
      freq=fmod(pcal_offset+i*1e6+16e6,32e6)-16e6;
      cycle->pcal_amp[i]*=rdbe_freqz(freq);
    }
    cycle->pcal_phase[i]=atan2(y[i],x[i])*180/M_PI;
  }
#ifdef WEH
  printf(" pcal_ifx %d offset %f spacing %f\\n",t->pcal_ifx,pcal_offset,pcal_spacing);
  for (i=535;i<541;i++) {
    printf(" i %4d amp %10.4f phs %10.4f\n",
        i,cycle->pcal_amp[i],cycle->pcal_phase[i]);
  }
#endif
}
