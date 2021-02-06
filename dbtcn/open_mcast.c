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

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "ssize_t.h"
#include "packet.h"

#include "dbtcn.h"

int open_mcast(char mcast_addr[], int mcast_port, char mcast_if[], int *error_no) {

    struct sockaddr_in addr = {};
    addr.sin_family         = AF_INET;
    addr.sin_addr.s_addr    = htonl(INADDR_ANY);
    addr.sin_port           = htons(mcast_port);

    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
//        perror("Opening datagram socket error");
        *error_no=errno;
        return -1;
    }

    int yes = 1;
    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes)) < 0) {
//          perror("Setting SO_REUSEADDR error");
        *error_no=errno;
        close(sock);
        return -2;
    }

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr))) {
//        perror("Binding datagram socket error");
        *error_no=errno;
        close(sock);
        return -3;
    }

// get the address right before using it, so it isn't overwritten
    char *if_addr;
    int ierr = get_if_addr(mcast_if,&if_addr,error_no);
    if (ierr < 0) {
        close(sock);
        return -5+ierr;
    }

    struct ip_mreq mreq       = {};
    mreq.imr_multiaddr.s_addr = inet_addr(mcast_addr);
    mreq.imr_interface.s_addr = inet_addr(if_addr);

    if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0) {
//       perror("Adding multicast group error");
        *error_no=errno;
        close(sock);
        return -4;
    }

    return sock;
}
