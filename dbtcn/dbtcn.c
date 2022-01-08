/*
 * Copyright (c) 2020-2021 NVI, Inc.
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

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "ssize_t.h"
#include "packet.h"
#include "packet_unpack.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

static char me[]="dbtcn";
static int last = 0;

int main(int argc, char *argv[])
{
    int ip[5];
    char buf[sizeof(dbbc3_ddc_multicast_t)];
    int it[6], itmc[6];
    int centisec[6];
    int seconds;

    setup_ids();    /* attach to the shared memory */
    rte_prior(FS_PRIOR);

    putpname(me);

    skd_wait(me,ip,(unsigned) 0);

    if( DBBC3 != shm_addr->equip.rack ||
            0==shm_addr->dbbad.mcast_addr[0])
        goto idle;

    int error_no;
    int sock = open_mcast(shm_addr->dbbad.mcast_addr,
            shm_addr->dbbad.mcast_port,
            shm_addr->dbbad.mcast_if,
            &error_no);

    if(0>sock) {
        logitn(NULL,-10+sock,"dn",error_no);
        goto idle;
    }

    ssize_t n;
    struct dbtcn_control dbtcn_control;
    struct dbbc3_tsys_cycle cycle = {};
    int to_report;
    dbbc3_ddc_multicast_t packet = {};

    int cont_cal_save1 = 0;
    int cont_cal_save2 = 0;

    for (;;) {
        /* wait two cylces for TPIs to catch-up to cont cal turning on */
        int cont_cal0 = shm_addr->dbbc3_cont_cal.mode == 1;
        int cont_cal = cont_cal0 && cont_cal_save1 && cont_cal_save2;
        cont_cal_save2 = cont_cal_save1;
        cont_cal_save1 = cont_cal0;
        int swap_cal = shm_addr->dbbc3_cont_cal.polarity == 2 ||
            shm_addr->dbbc3_cont_cal.polarity == 3;

        memcpy(&dbtcn_control,
                &shm_addr->dbtcn.control[shm_addr->dbtcn.iping],
                sizeof(dbtcn_control));

        to_report=1!=dbtcn_control.to_error_off;

        n = read_mcast(sock,buf,sizeof(buf),to_report,itmc,centisec);

        if(n<0)
            continue;

        if (unmarshal_dbbc3_ddc_multicast_t(&packet, buf, n) < 0) {
            logit(NULL,-1,"dn");
            continue;
        }

        calc_ts(&packet,&cycle, cont_cal, swap_cal);

        update_shm(&packet,&cycle, itmc, centisec);

        /* check control to get the last state before logging */

        memcpy(&dbtcn_control,
                &shm_addr->dbtcn.control[shm_addr->dbtcn.iping],
                sizeof(dbtcn_control));

        if (1==dbtcn_control.stop_request ||
                (dbtcn_control.continuous == 0 &&
                 (dbtcn_control.data_valid.user_dv ==0 || shm_addr->KHALT !=0 ||
                  0==strncmp(shm_addr->LSKD,"none    ",8)))) {
            last=0;
            continue;
        }

        rte_time(it,it+5);
        rte2secs(it,&seconds);

        if( 0 != last && seconds-last < (dbtcn_control.cycle+99)/100)
            continue;

        last=seconds;
        log_mcast(&packet,&cycle,cont_cal, swap_cal);
    }

idle:
    for (;;)
        skd_wait(me,ip,(unsigned) 0);
}
