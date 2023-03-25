/*
 * Copyright (c) 2020-2021, 2023 NVI, Inc.
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
/* DBBC3 mcast_time snap command */

#include <stdio.h> 
#include <string.h> 
#include <time.h> 
#include <math.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

void dbbc3_mcast_time(command,itask,ip)
    struct cmd_ds *command;                /* parsed command structure */
    int itask;
    int ip[5];                           /* ipc parameters */
{
    int ierr, i, it[6], seconds;
    char output[MAX_OUT];

    if(NULL!=command->argv[0]) {
        ierr=-301;
        goto error;
    }

    rte_time(it,it+5);
    rte2secs(it,&seconds);
    time_t now = seconds;

    ip[0]=ip[1]=ip[2]=0;

    int iping=shm_addr->dbbc3_tsys_data.iping;
    struct tm *ptr=gmtime(&shm_addr->dbbc3_tsys_data.data[iping].last);

    strcpy(output,command->name);
    strcat(output,"/");
    sprintf(output+strlen(output),
            " %d, %4d.%03d.%02d:%02d:%02d, %d, %d",
            0,
            ptr->tm_year+1900,
            ptr->tm_yday+1,
            ptr->tm_hour,
            ptr->tm_min,
            ptr->tm_sec,
            seconds-shm_addr->dbbc3_tsys_data.data[iping].last,
            shm_addr->dbbc3_tsys_data.data[iping].hsecs);
    cls_snd(&ip[0],output,strlen(output),0,0);
    ip[1]++;

    int most=0;
    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++)
        if( shm_addr->dbbc3_tsys_data.data[iping].ifc[i].delay > most)
            most=shm_addr->dbbc3_tsys_data.data[iping].ifc[i].delay;

    int digits_d=1;
    if (most > 9)
        digits_d=log10(most)+1;

    most=0;
    int sign_e = 1;
    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
        int mag=shm_addr->dbbc3_tsys_data.data[iping].ifc[i].time_error;
        int sign=1;
        if (mag < 0) {
            mag=-mag;
            sign = -1;
        }
        if( mag > most) {
            most=mag;
            sign_e=sign;
        }
    }

    int digits_e=1;
    if (most > 9)
        digits_e=log10(most)+1;
    if(sign_e <0)
        digits_e++;

    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
        ptr=gmtime(&shm_addr->dbbc3_tsys_data.data[iping].ifc[i].time);

        strcpy(output,command->name);
        strcat(output,"/");
        if (!shm_addr->dbbc3_tsys_data.data[iping].ifc[i].time_included)
            sprintf(output+strlen(output),
                    " %d,,, %*ue-9",
                    i+1,
                    digits_d,
                    shm_addr->dbbc3_tsys_data.data[iping].ifc[i].delay);
        else
            sprintf(output+strlen(output),
                    " %d, %4d.%03d.%02d:%02d:%02d,, %*ue-9, %*d",
                    i+1,
                    ptr->tm_year+1900,
                    ptr->tm_yday+1,
                    ptr->tm_hour,
                    ptr->tm_min,
                    ptr->tm_sec,
                    digits_d,
                    shm_addr->dbbc3_tsys_data.data[iping].ifc[i].delay,
                    digits_e,
                    shm_addr->dbbc3_tsys_data.data[iping].ifc[i].time_error);

        cls_snd(&ip[0],output,strlen(output),0,0);
        ip[1]++;
        output[0]=0;
    }
    int overall_error = 0;
    if(seconds - shm_addr->dbbc3_tsys_data.data[iping].last > 20) {
        logit(NULL,-302,"dw");
        overall_error=1;
    }
    for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++)
        if(shm_addr->dbbc3_tsys_data.data[iping].ifc[i].time_error!=0) {
            logitn(NULL,-303,"dw",i+1);
            overall_error=1;
        }

    if(overall_error) {
        ip[2]=-304;
        memcpy(ip+3,"dw",2);
    }
    return;

error:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"dw",2);
    return;
}
