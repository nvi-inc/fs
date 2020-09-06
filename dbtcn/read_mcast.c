/*
 * Copyright (c) 2020 NVI, Inc.
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
#include <netinet/in.h>
#include <sys/select.h>

#include "packet.h"
#include "packet_unpack.h"
#include "dbtcn.h"

// These are in centiseconds
#define TIME_OUT        400
#define ERROR_PERIOD   2000

size_t read_mcast(int sock, char buf[], size_t buf_size)
{
    ssize_t n;
    struct sockaddr_in from;
    socklen_t len = sizeof(from);

    struct timeval to;
    fd_set readfds;
    int return_select;
    int mcast_error = 0;
    int mcast_to    = 0;
    int old_error = 0;

    for (;;) {
        /* Read when data available */
        FD_ZERO(&readfds);
        FD_SET(sock, &readfds);
        to.tv_sec=TIME_OUT/100;
        to.tv_usec=(TIME_OUT%100)*10000;

        return_select = select(sock + 1, &readfds, NULL, NULL, &to);
        if(return_select == 0) {
            mcast_to=mcast_to%(ERROR_PERIOD/TIME_OUT) + 1;
            if(1==mcast_to) {
              logit(NULL,-20,"dn");
            }
          continue;
        } else if (return_select < 0) { /* error */
            if(old_error != errno)
                mcast_error = 0;
          mcast_error=mcast_error%(ERROR_PERIOD/100) + 1;
          if(1==mcast_error) {
            logitn(NULL,-21,"dn",errno);
          }
          old_error=errno;
          rte_sleep(100);
          continue;
        }
        if(mcast_to) {
          mcast_to=0;
          logit(NULL,20,"dn");
        }
        if(mcast_error) {
          mcast_error=0;
          old_error = 0;
          logit(NULL,21,"dn");
        }

        if ((n = recvfrom(sock, buf, buf_size, 0,
            (struct sockaddr *)&from, &len)) < 0) {
            logitn(NULL,-22,"dn",errno);
            continue;
        }
        return n;
    }
}
