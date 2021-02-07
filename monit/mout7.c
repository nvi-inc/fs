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
/* mout7 - RDBE monitor
 *
 */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>
#include <time.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "mon6.h"

extern struct fscom *fs;

static char unit_letters[ ] = {"ABCDEFGH"};
static struct tm tm_save;

void mout7( int next, struct dbbc3_tsys_cycle *tsys_cycle, int krf, int all, int def)
{
    struct dbbc3_tsys_ifc ifc;
    struct dbbc3_tsys_bbc bbc[MAX_DBBC3_BBC];
    char buf[128];
    int i;

    memcpy(&ifc,&tsys_cycle->ifc[next],sizeof(ifc));
    memcpy(&bbc,tsys_cycle->bbc,sizeof(bbc));

    move(0,0);
    printw("IF %c",unit_letters[next]);
    printw(" LO ");
    if(ifc.lo>=0.0) {
        buf[0]=0;
        dble2str(buf,ifc.lo,-8,1);
        printw("%8s",buf);
    } else
        printw("%8s"," ");

    if(1==ifc.sideband)
        printw("%4s"," USB");
    else if(2==ifc.sideband)
        printw("%4s"," LSB");
    else
        printw("%4s"," ");

    if(def)
        printw("%4s"," Def");
    else if(all)
        printw("%4s"," All");
    else
        printw("%4s"," Rec");

    move(1,0);
    printw("Delay");
    if(ifc.delay>=0) {
        buf[0]=0;
        int2str(buf,ifc.delay,-8,0);
        printw("%8s",buf);
    } else
        printw("%8s"," ");

    printw(" Tsys ");
    if(ifc.tsys> -1e12) {
        buf[0]=0;
        dble2str(buf,ifc.tsys,-5,1);
        printw("%5s",buf);
    } else
        printw("%5s"," ");

    move(2,0);
    printw("Time ");

    clock_t now=time(NULL);
    struct tm *ptr=gmtime(&now);
    if(ptr->tm_mon<6) {
        ptr->tm_mon=0;
        --ptr->tm_year;
    } else
        ptr->tm_mon=6;
    ptr->tm_mday=1;
    ptr->tm_hour=0;
    ptr->tm_min=0;
    ptr->tm_sec=0;
    clock_t epoch=mktime(ptr);
    clock_t vdif=ifc.time+epoch;
    ptr=gmtime(&vdif);

    int tm_different =
            ptr->tm_year != tm_save.tm_year ||
            ptr->tm_mon  != tm_save.tm_mon  ||
            ptr->tm_mday != tm_save.tm_mday ||
            ptr->tm_hour != tm_save.tm_hour ||
            ptr->tm_min  != tm_save.tm_min  ||
            ptr->tm_sec  != tm_save.tm_sec;

    if(!ifc.time_correct||!tm_different)
        standout();

    printw("%4d/%02d/%02d %02d:%02d:%02d",
            ptr->tm_year+1900,
            ptr->tm_mon+1,
            ptr->tm_mday,
            ptr->tm_hour,
            ptr->tm_min,
            ptr->tm_sec);

    if(!ifc.time_correct||!tm_different)
        standend();

    memcpy(&tm_save,ptr,sizeof(tm_save));

    move(3,0);
    if(krf)
        printw("BBC     RF    Ts-U  Ts-L");
    else
        printw("BBC     IF    Ts-U  Ts-L");

    int itpis[MAX_DBBC3_DET] = {};

    mk5dbbc3d(itpis);

    for(i=0;i<fs->dbbc3_ddc_bbcs_per_if;i++) {
        int ibbc =next*8+i;
        if(i>=8)
            ibbc=next*8+64+i-8;
        move(4+i,0);
        printw("%03d",ibbc+1);
        if(bbc[ibbc].freq>0.0) {
            double freq=bbc[ibbc].freq*1e-6;
            if(ifc.lo>=0.0 && krf)
                if(1==ifc.sideband)
                    freq=ifc.lo+freq;
                else if(2==ifc.sideband)
                    freq=ifc.lo-freq;
            buf[0]=0;
            dble2str(buf,freq,-8,1);
            printw(" %8s",buf);
        } else
            printw(" %8s"," ");

        if (def || all || itpis[ibbc+MAX_DBBC3_BBC]) {
            if (bbc[ibbc].tsys_usb < -1e18) {
                printw(" ");
                standout();
                printw("%5s","Nccal");
                standend();
            } else if (bbc[ibbc].tsys_usb < -1e16) {
                printw(" ");
                standout();
                printw("%5s","N bbc");
                standend();
            } else if (bbc[ibbc].tsys_usb < -1e14) {
                printw(" ");
                standout();
                printw("%5s","N lo ");
                standend();
            } else if (bbc[ibbc].tsys_usb < -1e12) {
                printw(" ");
                standout();
                printw("%5s","Ntcal");
                standend();
            }else if (bbc[ibbc].tsys_usb > -1e12)  {
                buf[0]=0;
                dble2str(buf,bbc[ibbc].tsys_usb,-5,1);
                printw(" %5s",buf);
            }
        } else
                printw(" %5s"," ");

        if(def || all || itpis[ibbc              ]) {
            if (bbc[ibbc].tsys_lsb < -1e18) {
                printw(" ");
                standout();
                printw("%5s","Nccal");
                standend();
            } else if (bbc[ibbc].tsys_lsb < -1e16) {
                printw(" ");
                standout();
                printw("%5s","N bbc");
                standend();
            } else if (bbc[ibbc].tsys_lsb < -1e14) {
                printw(" ");
                standout();
                printw("%5s","N lo ");
                standend();
            } else if (bbc[ibbc].tsys_lsb < -1e12) {
                printw(" ");
                standout();
                printw("%5s","Ntcal");
                standend();
            } else if (bbc[ibbc].tsys_lsb > -1e12) {
                buf[0]=0;
                dble2str(buf,bbc[ibbc].tsys_lsb,-5,1);
                printw(" %5s",buf);
            }
        } else
            printw(" %5s"," ");
    }

}
