/*
 * Copyright (c) 2020, 2022, 2023, 2025 NVI, Inc.
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
#include <sys/types.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet_r2dbe.h"
#include "packet_r2dbe_unpack.h"

extern struct fscom *shm_addr;

int r2dbe(char me[5], char who[2], char letter, int irdbe)
{
    char buf[sizeof(r2dbe_multicast_t)];
    int ip[5];
    struct r2dbe_tsys_cycle cycle;
    r2dbe_multicast_t packet = {};

    int error_no;
    int sock = open_mcast(shm_addr->rdbad[irdbe].mcast_addr,
            shm_addr->rdbad[irdbe].mcast_port,
            shm_addr->rdbad[irdbe].mcast_if,
            &error_no);

    if(0>sock) {
        logit(NULL,errno,"un");
        logita(NULL,-40+sock,"rz",who);
        goto idle;
    }

    for (;;) {
      ssize_t n = read_mcast(sock,buf,sizeof(buf),&cycle,who);

#ifdef WEH
      printf(" me '%5s' n %d\n",me, n);
#endif
      if(n<0)
        continue;

      if (unmarshal_r2dbe_multicast_t(&packet, buf, n) < 0) {
        logit(NULL,-31,"rz");
        continue;
      }
#ifdef WEH
      printf(" time '%32s'\n",packet.read_time);
      printf(" pkt_size %u epoch %u seconds %d\n",
          packet.pkt_size,packet.epoch_ref,packet.epoch_sec);
      printf("  mu0 %g sigma0 %g\n",
          packet.mu0,packet.sigma0);
      printf("  mu1 %g sigma1 %g\n",
          packet.mu1,packet.sigma1);
      printf("  pps %g gps %g\n",
          packet.pps_offset,packet.gps_offset);

      printf(" pcal_ifx %d\n",packet.pcal_ifx);
      printf(" pcal_freq %g\n",packet.pcal_freq);
      int i;
      for (i=0;i<8;i++)
         printf(" i %d, ibc0 %f ibc1 %f\n",i,packet.ibc0[i],packet.ibc1[i]);
#endif
//      calc_ts(&packet,&cycle);
      calc_pc(&packet,&cycle,irdbe);
      update_shm(&packet,&cycle,irdbe);
      log_mcast(&packet,&cycle,letter,irdbe);
     }

idle:
    for (;;)
        skd_wait(me,ip,(unsigned) 0);
}
