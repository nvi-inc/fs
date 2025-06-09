/*
 * Copyright (c) 2020-2023, 2025 NVI, Inc.
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
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

// These are in centiseconds
#define TIME_OUT        145
#define ERROR_PERIOD   2000

ssize_t read_mcast(int sock, char buf[], size_t buf_size,
         struct r2dbe_tsys_cycle *cycle, char who[2])
{
    ssize_t n;
    struct sockaddr_in from;
    socklen_t len = sizeof(from);

    struct timeval to;
    fd_set readfds;
    static int mcast_error = 0;
    static int old_error = 0;
    int return_select;
    int time_out;
    int it[6];
    int seconds;

    /* set time-out */
    time_out=TIME_OUT;

    FD_ZERO(&readfds);
    FD_SET(sock, &readfds);
    to.tv_sec=time_out/100;
    to.tv_usec=(time_out%100)*10000;

    /* Check if data available */
    return_select = select(sock + 1, &readfds, NULL, NULL, &to);
    if(return_select == 0) {  /* time-out */
      logita(NULL,-20,"rz",who);
      return -1;
    } else if (return_select < 0) { /* error */
      if(old_error != errno)
          mcast_error = 0;
      mcast_error=mcast_error%(ERROR_PERIOD/100) + 1;
      if(1==mcast_error) {
          logit(NULL,errno,"un");
          logita(NULL,-21,"rz",who);
      }
      old_error=errno;
      rte_sleep(100);
      return -1;
    }

    if(mcast_error) {
        mcast_error=0;
        old_error = 0;
        logit(NULL,21,"rz");
    }

    if ((n = recvfrom(sock, buf, buf_size, 0,
        (struct sockaddr *)&from, &len)) < 0) {
        logit(NULL,errno,"un");
        logita(NULL,-22,"rz",who);
        rte_sleep(100);
        return -1;
    }

    rte_time(it,it+5);
    rte2secs(it,&seconds);
    cycle->arrival=seconds;

    return n;
}
