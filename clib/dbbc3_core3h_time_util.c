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

void dbbc3_core3h_time_mon(output,count,lcl)
char *output;
int *count;
struct dbbc3_core3h_time_mon *lcl;
{
    int ind;
    struct tm *tm;
    time_t tmv;

    output=output+strlen(output);

    switch (*count) {
      case 1:
	sprintf(output,"%d",lcl->iboard);
	break;
      case 2:
	sprintf(output,"%d",lcl->vdif_epoch);
	break;
      case 3:
	sprintf(output,"%d",lcl->seconds);
	break;
      case 4:
	sprintf(output,"%d",lcl->days);
	break;
      case 5:
	snprintf(output,sizeof(lcl->time),"%s",lcl->time);
	break;
      case 6:
        tmv=lcl->seconds_fm;
        tm=gmtime(&tmv);
        if(tm) {
            int vdif_should=(tm->tm_year-100)%32;
            vdif_should=vdif_should*2+tm->tm_mon/6;
            sprintf(output,"(%d)",vdif_should);
        }
        break;
      case 7:
	sprintf(output,"%d",lcl->seconds_fm-lcl->seconds_fs);
	break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

int dbbc3_2_core3h_time(irec,lclm,buff)
int irec;
struct dbbc3_core3h_time_mon *lclm;
char *buff;
{
    int month,day,it[6],centisec[6],time32;
    switch(irec) {
        case 1:
        case 6:
            return 0;
            break;
        case 0:
            if(1!=sscanf(buff,"Core3H[%d",&lclm->iboard))
                return -1;
            break;
        case 2:
            if(1!=sscanf(buff,"\rhalfYearsSince2000 = %d",&lclm->vdif_epoch))
                return -1;
            break;
        case 3:
            if(1!=sscanf(buff,"\rseconds = %d",&lclm->seconds))
                return -1;
            break;
        case 4:
            if(1!=sscanf(buff,"\rdaysSince2000 = %d",&lclm->days))
                return -1;
            break;
        case 5:
            if(6!=sscanf(buff,"\r%d-%d-%dT%d:%d:%d",
                        &it[5],&month,&day,
                        &it[3],&it[2],&it[1]))
                return -1;
            it[4]=daymy(it[5],month,day);
            it[0]=0;
            memcpy(lclm->time,buff+1,sizeof(lclm->time));
            rte2secs(it,&time32);
            lclm->seconds_fm=time32;
#ifdef DEBUG
            printf(" get_core3htime: fm_time decode %d %d %d %d %d %d doy %d\n",
                    it[5],month,day,it[3],it[2],it[1],it[4]);
#endif
            break;
        case 7:
            memcpy(centisec,buff,sizeof(centisec));
            rte_fixt(&time32,&centisec[0]);
            lclm->seconds_fs=time32;
#ifdef DEBUG
            printf(" get_core3htime: centisecs %d %d %d %d %d %d\n",
                    centisec[0],centisec[1],centisec[2],centisec[3],centisec[4],
                    centisec[5]);
#endif
            break;
        default:
            return -1;
    }


    return 0;
}
