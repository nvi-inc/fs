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
#include <math.h>

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

static void pc_cat(char buf[],double ts)
{
    if(ts < 0.0) /* only allow moving decimal for negatives */
        dble2str_j(buf,ts,-5,1);
    else
       dble2str(buf,ts,-5,1);
    strcat(buf,",");
}

static void log_pc( struct r2dbe_tsys_cycle *cycle, char buf[], char letter,int ifp, int irdbe)
{
    int i, j, k;
    int active_chan[MAX_R2DBE_CH];

    if(cycle->pcal_offset < 0.0)
      return;

    if(ifp<0 || ifp>=MAX_RDBE_IF || !shm_addr->rdbe_channels[irdbe+1].ifc[ifp].channels.state.known)
      return;

    for (k=0;k<MAX_R2DBE_CH;k++)
        active_chan[k]=0;
    for (j=0;j<MAX_R2DBE_CH;j++) {
      int chan=shm_addr->rdbe_channels[irdbe+1].ifc[ifp].channels.channels[j];
      if(chan>=0 && chan<MAX_R2DBE_CH)
        active_chan[chan]=1;
    }

    if(cycle->tone0 < 0)
      return;

    for (i=cycle->tone0;i<4096/2;i+=rint(cycle->pcal_spacing*1e-6)) {
      int ibin; /* find channel of tone, critical cases round up */
      ibin=fmod((cycle->pcal_offset+i*1e6+16e6)/32e6+1e-12,(double)MAX_R2DBE_CH);
      if(!active_chan[ibin])
        continue;
      log_out(buf, "pcal/",7+10+8,0);
      sprintf(buf+strlen(buf)," %u%c%04d, %8.3f, %6.1f,",ifp,letter,i,cycle->pcal_amp[i],cycle->pcal_phase[i]);
    }
    log_out(buf, "",0,0);
}

void log_mcast(r2dbe_multicast_t *t, struct r2dbe_tsys_cycle *cycle, char letter, int irdbe)
{
    char buf[256] = "";

       log_time( cycle, buf);
       log_pc( cycle, buf, letter, cycle->pcal_ifx, irdbe);

}
