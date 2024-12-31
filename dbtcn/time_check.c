/*
 * Copyright (c) 2023-2024 NVI, Inc.
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

#include <ctype.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

static int time_error = 0;

char *getenv_DBBC3( char *env, int *actual, int *nominal, int *error, int options);

void time_check( struct dbbc3_tsys_cycle *cycle)
{
    int i, j;
    int time_agrees=1;
    static int minutes=-1;

    for (i=0; i<shm_addr->dbbc3_ddc_ifs;i++)
        if(cycle->ifc[i].time_included) {
            for (j=i+1; j<shm_addr->dbbc3_ddc_ifs;j++)
                if(cycle->ifc[j].time_included &&
                        cycle->ifc[i].time!=cycle->ifc[j].time) {
                     time_agrees=0;
                     break;
                }
            break;
         }

     if(0>minutes) {
         int actual, error;
         char *ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_TIME_ERROR_MINUTES",&actual,NULL,&error,1);
         if(0==error)
             minutes=actual;
         else
             minutes=1;
     }
     if(time_agrees && time_error) {
         logit(NULL,24,"dn");
         time_error=0;
     } else if (!time_agrees) {
         int report=FALSE;
         if(!time_error || 0>minutes)
             report=TRUE;
         else if(0 < minutes) {
             int now;
             rte_ticks(&now);
             if((now-time_error+99)/(60*100*minutes) > 0) {
                 report=TRUE;
             }
         }
         if(report) {
             logit(NULL,-24,"dn");
             rte_ticks(&time_error);
         }
     }

     return;
}
