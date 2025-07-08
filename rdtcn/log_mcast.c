/*
 * Copyright (c) 2023 NVI, Inc.
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
#include <time.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet_r2dbe.h"

extern struct fscom *shm_addr;

static void if_cat(char buf[],unsigned int tp)
{
    uns2str2(buf,tp,-9,0);
    strcat(buf,",");
}

static void bb_cat(char buf[],unsigned int tp)
{
    uns2str2(buf,tp,-5,0);
    strcat(buf,",");
}

static void ts_cat(char buf[],double ts)
{
    if(ts < 0.0) /* only allow moving decimal for negatives */
        dble2str_j(buf,ts,-5,1);
    else
       dble2str(buf,ts,-5,1);
    strcat(buf,",");
}

static void dt_cat(char buf[],char dt[4])
{
    strcat(buf," ");

    int len=strlen(buf);
    strncat(buf,dt,4);
    buf[len+4]=0;
    strcat(buf,",");
}

static void log_out(char buf[],char *string, int new, int disp)
{
    static int slen = 0;

    /* time-tag is 20 charaters (+1 for ms digit, someday) +7 for #rdtcX#,
       so usable width to 79 characters is 51 = 79-28, but we can go bigger
        78 = 106-28 standard login shell,
        110 = 138-28 is for Tsys of 8 BBCs SSB and 1 IF on one line
     */
    if((strlen(buf)+new >  110 || strlen(string)==0) && strlen(buf) > slen) {
        buf[strlen(buf)-1]=0;
        if(disp)
           logitf(buf,0,NULL);
        else
           logit(buf,0,NULL);
        buf[0]=0;
    }
    if(buf[0]==0 && strlen(string) !=0) {
        strcpy(buf,string);
        slen=strlen(buf);
    }
}
static void log_time( struct r2dbe_tsys_cycle *cycle, char buf[])
{
    int i;

    log_out(buf, "dot/",22,0);
    strcat(buf,cycle->epoch);
    sprintf(buf+strlen(buf),",%d,",cycle->epoch_vdif);

    log_out(buf, "",0,0);

    log_out(buf, "dot2pps/",22,0);
    sprintf(buf+strlen(buf),"%12.9e,",cycle->dot2pps);

    log_out(buf, "",0,0);

    log_out(buf, "dot2gps/",22,0);
    sprintf(buf+strlen(buf),"%12.9e,",cycle->dot2gps);

    log_out(buf, "",0,0);
}

//static void log_tp( r2dbe_multicast_t *t, char buf[], int cont_cal)
//{
//    unsigned on, off;
//    int j, k;
//
//    for (j=0;j<MAX_DBBC3_IF+1;j++) {
//        for (k=0;k<MAX_DBBC3_BBC;k++) {
//            if (shm_addr->tpicd.itpis[k] && shm_addr->tpicd.ifc[k] == j) {
//                if(cont_cal)
//                    log_out(buf, "tpcont/",17,0);
//                else
//                    log_out(buf, "tpi/",11,0);
//
//                dt_cat(buf,shm_addr->tpicd.lwhat[k]);
//
//                on =t->bbc[k].total_power_lsb_cal_on;
//                off=t->bbc[k].total_power_lsb_cal_off;
//
//                if(cont_cal) {
//                    bb_cat(buf,on);
//                    bb_cat(buf,off);
//                } else
//                    bb_cat(buf,on);
//            }
//            if (shm_addr->tpicd.itpis[k+MAX_DBBC3_BBC] && shm_addr->tpicd.ifc[k+MAX_DBBC3_BBC] == j) {
//                if(cont_cal)
//                    log_out(buf, "tpcont/",17,0);
//                else
//                    log_out(buf, "tpi/",11,0);
//
//                dt_cat(buf,shm_addr->tpicd.lwhat[k+MAX_DBBC3_BBC]);
//
//                on =t->bbc[k].total_power_usb_cal_on;
//                off=t->bbc[k].total_power_usb_cal_off;
//
//                if(cont_cal) {
//                    bb_cat(buf,on);
//                    bb_cat(buf,off);
//                } else
//                    bb_cat(buf,on);
//            }
//        }
//        if (j!= 0 && shm_addr->tpicd.itpis[j-1+MAX_DBBC3_BBC*2]) {
//            if(cont_cal)
//                log_out(buf, "tpcont/",25,0);
//            else
//                log_out(buf, "tpi/",15,0);
//
//            dt_cat(buf,shm_addr->tpicd.lwhat[j-1+MAX_DBBC3_BBC*2]);
//
//            on = t->core3h[j-1].total_power_cal_on;
//            off= t->core3h[j-1].total_power_cal_off;
//
//            if(cont_cal) {
//                if_cat(buf,on);
//                if_cat(buf,off);
//            } else
//                if_cat(buf,on);
//        }
//        log_out(buf, "",0,0);
//    }
//}

//static void log_ts( struct r2dbe_tsys_cycle *cycle, char buf[],
//                    int tsys_request)
//{
//    double tsys;
//    int j, k;
//
//    for (j=0;j<MAX_DBBC3_IF;j++) {
//        for (k=0;k<MAX_DBBC3_BBC;k++) {
//
//            if (shm_addr->tpicd.itpis[k] && shm_addr->tpicd.ifc[k] == j+1) {
//                tsys=cycle->bbc[k].tsys_lsb;
//
//                if (tsys > -1e12) {
//                    log_out(buf, "tsys/",11,tsys_request);
//                    dt_cat(buf,shm_addr->tpicd.lwhat[k]);
//                    ts_cat(buf,tsys);
//                }
//            }
//            if (shm_addr->tpicd.itpis[k+MAX_DBBC3_BBC] && shm_addr->tpicd.ifc[k+MAX_DBBC3_BBC] == j+1) {
//                tsys=cycle->bbc[k].tsys_usb;
//
//                if (tsys > -1e12) {
//                    log_out(buf, "tsys/",11,tsys_request);
//                    dt_cat(buf,shm_addr->tpicd.lwhat[k+MAX_DBBC3_BBC]);
//                    ts_cat(buf,tsys);
//                }
//
//            }
//        }
//        if (shm_addr->tpicd.itpis[j+MAX_DBBC3_BBC*2]) {
//            tsys=cycle->ifc[j].tsys;
//
//            if (tsys > -1e12) {
//                log_out(buf, "tsys/",9,tsys_request);
//                dt_cat(buf,shm_addr->tpicd.lwhat[j+MAX_DBBC3_BBC*2]);
//                ts_cat(buf,tsys);
//            }
//        }
//        log_out(buf, "",0,tsys_request);
//    }
//}

static void pc_cat(char buf[],double ts)
{
    if(ts < 0.0) /* only allow moving decimal for negatives */
        dble2str_j(buf,ts,-5,1);
    else
       dble2str(buf,ts,-5,1);
    strcat(buf,",");
}

static void log_pc( struct r2dbe_tsys_cycle *cycle, char buf[], char letter,int ifp)
{
    int i;

    if(cycle->pcal_offset < 0.0)
      return;
    for (i=0;i<4096/2;i++) {
        log_out(buf, "pcal/",11+6+8+7,0);
        sprintf(buf+strlen(buf)," %u%c%04d, %7.3f, %6.1f,",ifp,letter,i,cycle->pcal_amp[i],cycle->pcal_phase[i]);
    }
    log_out(buf, "",0,0);
}

void log_mcast(r2dbe_multicast_t *t, struct r2dbe_tsys_cycle *cycle, char letter)
{
    char buf[256] = "";

       log_time( cycle, buf);
       log_pc( cycle, buf, letter, cycle->pcal_ifx);
//       log_tp( t, buf, cont_cal);

//    if(0<samples && logging)
//        *count=++*count%samples;
//    if(cont_cal && (tsys_request || logging && (0>=samples || 0==*count)))
//        log_ts( cycle, buf, tsys_request);

//       log_pcal( cycle, buf,irdbe);
}
