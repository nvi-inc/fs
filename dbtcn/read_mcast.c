/*
 * Copyright (c) 2020-2026 NVI, Inc.
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

#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>
#include <sys/select.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;
#include "packet.h"
#include "packet_unpack.h"

#include "dbtcn.h"

// These are in centiseconds
#define TIME_OUT        500
#define ERROR_PERIOD   2000

#define MAX_RECV   60

char *getenv_DBBC3( char *env, int *actual, int *nominal, int *error, int options);

ssize_t read_mcast(int sock, char buf[], size_t buf_size, int it[6],
        int centisec[6],int data_valid, int *hsecs)
{
    ssize_t n;
    struct sockaddr_in from;
    socklen_t len = sizeof(from);

    struct timeval to;
    fd_set readfds;
    int return_select;
    static int mcast_error = 0;
    static int old_error = 0;
    static int to_count = -1;
    static int to_try = -1;
    static int was_dbbc3_cmd = 0;
    int time_out_summary_period=60;
    static int seconds0,seconds;

    static unsigned was_count_next = 0;
    unsigned was_count;
    static unsigned was_count_recv = 0;

    static int kfirst=TRUE;

    int it_start[6];

    static int recv[MAX_RECV];
    static int irecv;
    static int recv_start;
    static int percent=-1;
    static int was_recv_valid_error;

    if(!recv_start)
       rte_ticks(&recv_start);

/* use the command count before the PREVIOUS select() to decide
 * if there has been DBBC3 activity that could interfere
 */

    was_count=was_count_next;
    was_count_next=shm_addr->dbbc3_command_count;

    if(to_try > -1)
      to_try++;

    FD_ZERO(&readfds);
    FD_SET(sock, &readfds);

    /* set time-out */
    to.tv_sec=TIME_OUT/100;
    to.tv_usec=(TIME_OUT%100)*10000;

    /* Check if data available */
    rte_time(it_start,it_start+5);
    return_select = select(sock + 1, &readfds, NULL, NULL, &to);
    if(return_select == 0) {  /* time-out */
        int dbbc3_cmd=shm_addr->dbbc3_command_active ||
            shm_addr->dbbc3_command_count != was_count;

        if(!dbbc3_cmd) {
            /* it only counts as a try and a time-out
             * if we don't expect an error */

            if(!data_valid) {
//                logite(";\" INFO: multicast time-out with no DBBC3 commands while data_valid=off",0,NULL);
                logit_nd(" INFO: multicast time-out with no DBBC3 commands while data_valid=off",0,NULL);
            } else {
//                logite(";\" INFO: multicast time-out with no DBBC3 commands while data_valid=on",0,NULL);
                logit_nd(" INFO: multicast time-out with no DBBC3 commands while data_valid=on",0,NULL);
            }
            to_count++;
            if(to_count == 0) {
                if(!data_valid)
                    logit(NULL,-20,"dn");
                else
                    logit(NULL,-26,"dn");
                rte_time(it,it+5);
                seconds0=it[1]+60*it[2];
            }
        } else if(data_valid) {
            /* any time-out when data is valid counts */
//            logite(";\" INFO: multicast time-out with DBBC3 commands (or FMSET) while data_valid=on",0,NULL);
            logit_nd(" INFO: multicast time-out with DBBC3 commands (or FMSET) while data_valid=on",0,NULL);
            to_count++;
            if(to_count == 0) {
                logit(NULL,-23,"dn");
                rte_time(it,it+5);
                seconds0=it[1]+60*it[2];
            }
            logit(NULL,-27,"dn");
        } else {
//            logite(";\" INFO: multicast time-out with DBBC3 commands (or FMSET) while data_valid=off",0,NULL);
            logit_nd(" INFO: multicast time-out with DBBC3 commands (or FMSET) while data_valid=off",0,NULL);
            if(to_count > -1)
                to_count++;
        }
        if(to_count > -1) { /* only if there was a reportable time-out */
            if(to_try < 0)
                to_try=0;
            else {
                rte_time(it,it+5);
                seconds=it[1]+60*it[2];
                if(seconds<seconds0)
                     seconds+=3600;
                if(seconds-seconds0 >= time_out_summary_period) { /* summary if a time-out */
                    if(12==to_count)
                       logit(NULL,-28,"dn");
                    else
                       logitn(NULL,-25,"dn",to_count);
                    to_count=0;
                    to_try=0;
                    seconds0=it[1]+60*it[2];
                }
            }
        }
        was_dbbc3_cmd=dbbc3_cmd;
        return -1;
    } else if (return_select < 0) { /* error */
        if(old_error != errno)
            mcast_error = 0;
        mcast_error=mcast_error%(ERROR_PERIOD/100) + 1;
        if(1==mcast_error) {
            logitn(NULL,-21,"dn",errno);
        }
        old_error=errno;
        rte_sleep(100);
        return -1;
    }

    /* received */
    if(0>percent) {
        int actual, error;
        char *ptr;
        ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_MAXIMUM_LOSS_PERCENT",&actual,NULL,&error,1);
        if(0==error)
            percent=actual;
        else
            percent=10;
// debug percent:
//      printf(" percent %d\n",percent);
    }

    irecv=(irecv+1)%MAX_RECV;
    rte_ticks(recv+irecv);
    if(shm_addr->dbbc3_command_active ||
            shm_addr->dbbc3_command_count != was_count_recv) {
//            printf(" irecv %d recv[irecv] %d >was_recv+500 %d\n",
//                     irecv,recv[irecv],was_recv+500);
        if(!data_valid)
            rte_ticks(&recv_start);
        else if(to_count <= 0 && recv[irecv]>=was_recv_valid_error+500) { /* <= for not counting OR none so far */
            logit(NULL,-44,"dn");
            was_recv_valid_error=recv[irecv];
        }
    }
    was_count_recv=shm_addr->dbbc3_command_count;

    if(percent >= 0 && percent < 100) {
// debug percent:
//            int debug_ticks;
//            rte_ticks(&debug_ticks);
//            if(debug_ticks%6000 > 1500) {
//            printf(" debug_ticks%6000 %4d\n", debug_ticks%6000);
        if(recv_start<=recv[irecv]-60*100) {
            int i;
            int icount_recv=0;
            for(i=0;i<MAX_RECV;i++) {
// debug percent:
//                             printf(" i %2d recv[i] %d irecv %2d recv[irecv] %d recv[irecv]-60*100 %d recv_start %d\n",
//                                      i,recv[i],irecv,recv[irecv],recv[irecv]-60*100,recv_start);
                if(recv[i] > recv[irecv]-60*100)
                    icount_recv++;
            }
            int expected=60/(shm_addr->dbbc3_mcast_arrival/100+1);
            float factor=1-percent/100.0;
            int limit=expected*factor+0.5;
// debug percent:
//                     printf(" icount_recv %d max count %d\n", icount_recv,limit);
            if(icount_recv<limit && to_count < 0) { /* < for not counting */
                if(data_valid)
                    logitn(NULL,-29,"dn",(int) (0.5+100.0*(expected-icount_recv)/expected));
                else
                    logitn(NULL,29,"dn",(int) (0.5+100.0*(expected-icount_recv)/expected));
                rte_ticks(&recv_start);
            }
        }
// debug percent:
//           }
    }

    if(to_try > -1) { /* summary if NOT a time-out */
        rte_time(it,it+5);
        seconds=it[1]+60*it[2];
        if(seconds<seconds0)
             seconds+=3600;
        if(seconds-seconds0 >= time_out_summary_period) { /* summary if a time-out */
            if(0 == to_count) {
                logit(NULL,20,"dn");
                to_count=-1;
                to_try=-1;
                rte_ticks(&recv_start);
            } else {
                if(12==to_count)
                    logit(NULL,-28,"dn");
                else
                    logitn(NULL,-25,"dn",to_count);
                to_count=0;
                to_try=0;
                seconds0=it[1]+60*it[2];
            }
        }
    }

    if(mcast_error) {
        mcast_error=0;
        old_error = 0;
        logit(NULL,21,"dn");
    }

    if ((n = recvfrom(sock, buf, buf_size, 0,
        (struct sockaddr *)&from, &len)) < 0) {
        logitn(NULL,-22,"dn",errno);
        rte_sleep(100);
        return -1;
    }
    /* get time received */
    rte_time(it,it+5);
    rte_ticks (centisec);
    rte_cmpt(centisec+2,centisec+4);
    centisec[1]=centisec[0];
    centisec[3]=centisec[2];
    centisec[5]=centisec[4];
    if(it[1]==it_start[1])
        *hsecs=it[0]-it_start[0];
    else {
        *hsecs=(it[1]-(it_start[1]+1))*100+it[0];
        if (*hsecs<0)
            *hsecs+=6000;
    }
    if(!kfirst) { /* The timing of the first try is not reliable, so ignore */
        int diff=*hsecs/100-shm_addr->dbbc3_mcast_arrival/100;
        if(diff!=0) {
            char buff[128];
            sprintf(buff," INFO: multicast arrived %d second(s) later than expected",diff);

//            logite(buff,0,NULL);
            logit_nd(buff,0,NULL);
        }
    } else
        kfirst=FALSE;

    return n;
}
