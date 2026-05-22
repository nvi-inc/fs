/*
 * Copyright (c) 2026 NVI, Inc.
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
/* dbbc3 coreh3_time buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <time.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void dbbc3_pps_delay_mon(output,count,lcl)
char *output;
int *count;
struct dbbc3_pps_delay_mon *lcl;
{
    int ind;
    struct tm *tm;
    time_t tmv;

    if(*count>shm_addr->dbbc3_ddc_ifs) {
        *count=-1;
        return;
    }

    output=output+strlen(output);

    sprintf(output," %d",lcl->pps_delay[*count-1]);
    if(*count > 0) *count++;
    return;
}

int dbbc3_2_pps_delay(irec,lclm,buff)
int irec;
struct dbbc3_pps_delay_mon *lclm;
char *buff;
{
    int i;
    char *ptr;

    ptr=strchr(buff,':');
    if(NULL==ptr)
        return -1;

    for(i=0;i<shm_addr->dbbc3_ddc_ifs-1;i++) {
        if(1!=sscanf(ptr+1,"%d",lclm->pps_delay+i))
            return -1;
        ptr=strchr(ptr+1,']');
        if(NULL==ptr)
            return -1;
    }
    if(1!=sscanf(ptr+1,"%d",lclm->pps_delay+shm_addr->dbbc3_ddc_ifs-1))
        return -1;

    return 0;
}
