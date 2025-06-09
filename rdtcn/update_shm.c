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

#include <time.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet_r2dbe.h"

extern struct fscom *shm_addr;

void update_shm( r2dbe_multicast_t *t, struct r2dbe_tsys_cycle *cycle,
       int irdbe)
{
  int i, j;
  int iping;
  struct rdbe_tsys_cycle r1dbe_cycle;
  struct rdbe_tsys_cycle1 r1dbe_cycle1;

  memcpy(cycle->epoch,t->read_time,sizeof(cycle->epoch));
  cycle->epoch[sizeof(cycle->epoch)-1]=0;
  cycle->epoch_vdif=t->epoch_ref;

#ifdef WEH
{
    int it[6];
    rte_time(it,it+5);
    struct timeval tv;
    gettimeofday(&tv,NULL);
    printf("rdbe %d seconds %10d us %6d ms %4d\n",irdbe,tv.tv_sec,tv.tv_usec,tv.tv_usec/1000);
    printf(" irdbe %d t->epoch_sec '%d' cycle->epoch '%s'\n",irdbe,t->epoch_sec,cycle->epoch);
    printf("  irdbe %d time %4d %3d %2d %2d %2d %2d\n",irdbe,it[5],it[4],it[3],it[2],it[1],it[0]);
}
#endif

 cycle->dot2gps=t->gps_offset;
 cycle->dot2pps=t->pps_offset;
 cycle->pcal_ifx=t->pcal_ifx;

 cycle->sigma[0]=t->sigma0;
 cycle->sigma[1]=t->sigma1;
#ifdef WEH
 printf(" epoch_ref %d epoch_vdif %d\n",t->epoch_ref,cycle->epoch_vdif);
 printf(" gps: cycle %g t %g\n",cycle->dot2gps,t->gps_offset);
 printf(" pps: cycle %g t %g\n",cycle->dot2pps,t->pps_offset);

printf("updating shared memory irdbe=%d\n",irdbe);
#endif

 int channel1=MAX_R2DBE_CH;
 for(i=0;i<MAX_R2DBE_CH;i++)
   for (j=0;j<MAX_R2DBE_IF;j++) {
   if(shm_addr->rdbe_channels[irdbe+1].ifc[j].channels.channels[i]>=0 &&
      shm_addr->rdbe_channels[irdbe+1].ifc[j].channels.channels[i]<channel1)
     channel1=shm_addr->rdbe_channels[irdbe+1].ifc[j].channels.channels[i];
   }
 int tone0=pcal_tone0_r2dbe(channel1-1,cycle->pcal_offset,cycle->pcal_spacing);
 cycle->tone0=tone0;

  iping=1-shm_addr->r2dbe_tsys_data[irdbe].iping;
  if(iping!=0)
    iping=1;
  memcpy(&shm_addr->r2dbe_tsys_data[irdbe].data[iping],cycle,
         sizeof(struct r2dbe_tsys_cycle));
  shm_addr->r2dbe_tsys_data[irdbe].iping=iping;

  memcpy(r1dbe_cycle.epoch,cycle->epoch,sizeof(r1dbe_cycle.epoch));
  r1dbe_cycle.epoch_vdif=cycle->epoch_vdif;

 if(tone0 >=0 )
   for (i=0;i<512;i++) {
     r1dbe_cycle.pcal_amp[i]=cycle->pcal_amp[i+tone0];
     r1dbe_cycle.pcal_phase[i]=cycle->pcal_phase[i+tone0];
   }

 r1dbe_cycle.pcal_ifx=cycle->pcal_ifx;;
 if(0==cycle->pcal_ifx)
    r1dbe_cycle.sigma=t->sigma0;
 else
    r1dbe_cycle.sigma=t->sigma1;
 r1dbe_cycle.raw_ifx=cycle->pcal_ifx;

 r1dbe_cycle.dot2gps=cycle->dot2gps;
 r1dbe_cycle.dot2pps=cycle->dot2pps;

 r1dbe_cycle.pcaloff=cycle->pcal_offset;
 r1dbe_cycle.pcal_spacing=cycle->pcal_spacing;

 r1dbe_cycle1.arrival=cycle->arrival;

  iping=1-shm_addr->rdbe_tsys_data[irdbe].iping;
  if(iping!=0)
    iping=1;
  memcpy(&shm_addr->rdbe_tsys_data[irdbe].data[iping],&r1dbe_cycle,
         sizeof(struct rdbe_tsys_cycle));
  memcpy(&shm_addr->rdbe_tsys_data1[irdbe].data[iping],&r1dbe_cycle1,
         sizeof(struct rdbe_tsys_cycle1));
  shm_addr->rdbe_tsys_data[irdbe].iping=iping;

}
