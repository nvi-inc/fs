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
#include <string.h>
#include <stdio.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

int get_if_addr(char *name, char **address, int *error_no)
{
    struct ifreq ifr;
    size_t len=strlen(name);
    if (len>=sizeof(ifr.ifr_name)) {
        *error_no=sizeof(ifr.ifr_name)-1;
        return -1;
    } else {
        memcpy(ifr.ifr_name,name,len);
        ifr.ifr_name[len]=0;
    }

    int fd=socket(AF_INET,SOCK_DGRAM,0);
    if (-1 == fd) {
       *error_no=errno;
       return -2;
    }

    if (-1 == ioctl(fd,SIOCGIFADDR,&ifr)) {
        *error_no=errno;
        close(fd);
        return -3;
    }
    close(fd);

    *address=inet_ntoa(((struct sockaddr_in*) &ifr.ifr_addr)->sin_addr);

    return 0;
}
/* test
int main(int argc, char **argv) {
    char *address;
    int error, error_no;

    if (argc==0)
        return 0;

    error=get_if_addr(argv[1], &address, &error_no);
    if(error) {
       printf("No address, error %d",error);
       if (-3==error)
           printf(", %s", strerror(error_no));
       printf("\n");
    } else
       printf("address: %s\n", address);

    return 0;
}
*/
