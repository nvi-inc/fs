/*
 * Copyright (c) 2020-2024 NVI, Inc.
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
#include <limits.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "mon7.h"

#define WARN1 2
#define WARN2 5
#define HIGHLIGHT(COLOR) if(has_colors()) \
                           attron(COLOR_PAIR(COLOR)); \
                         else \
                           standout();

extern struct fscom *fs;

static char unit_letters[ ] = {"ABCDEFGH"};
static time_t save_disp_time;
static int kfirst = 1;

static void print_tsys(float tsys, unsigned clipped, int reverse)
{
    char buf[128];

    if (tsys < -1e20)
        printw("%5s"," ");
    else if (tsys < -1e18) {
        standout();
        printw("%5s","N bbc");
    } else if (tsys < -1e16) {
        standout();
        printw("%5s","N lo ");
    } else if (tsys < -1e14) {
        standout();
        printw("%5s","NTcal");
    } else if (tsys < -1e12) {
        standout();
        printw("%5s","N cal");
    } else if (tsys < -1e6) {
        if(!reverse)
            HIGHLIGHT(CYAN)
        else
            HIGHLIGHT(CYANI)
        if (tsys < -1e10)
            printw("%5s","ovrfl");
        else if (tsys < -1e9)
            printw("%5s","tpi=0");
        else if (tsys < -1e8)
            printw("%5s","off=0");
        else if (tsys < -1e7)
            printw("%5s"," on=0");
        else if (tsys < -1e6)
            printw("%5s"," inf ");
    } else if (tsys <= -999.5) {
        standout();
        printw("%5s","$$$$$");
    } else if (999.95 <= tsys) {
        printw("%5s","$$$$$");
    } else {
        buf[0]=0;
        if(0==clipped) {
            if(tsys < 0.0)
               standout();
        } else if(clipped == UINT_MAX)
            if(!reverse)
                HIGHLIGHT(BLUE)
            else
                HIGHLIGHT(BLUEI)
        else if(clipped <= WARN1)
            if(!reverse)
               HIGHLIGHT(GREEN)
            else
               HIGHLIGHT(GREENI)
        else if(clipped <= WARN2)
            if(!reverse)
               HIGHLIGHT(YELLOW)
            else
               HIGHLIGHT(YELLOWI)
        else
            if(!reverse)
               HIGHLIGHT(RED)
            else
               HIGHLIGHT(REDI)
         dble2str_j(buf,tsys,-5,1);
         printw("%5s",buf);
    }
    standend();
}
void mout7( int next, struct dbbc3_tsys_cycle *tsys_cycle, int krf, int all,
        int def, int rec, int reverse, int late)
{
    struct dbbc3_tsys_ifc ifc;
    struct dbbc3_tsys_bbc bbc[MAX_DBBC3_BBC];
    char buf[128];
    int i;
    static time_t disp_time = 0;
    struct tm *ptr;
    int irow=0;

    memcpy(&ifc,&tsys_cycle->ifc[next],sizeof(ifc));
    memcpy(&bbc,tsys_cycle->bbc,sizeof(bbc));

    move(irow++,0);
    printw("IF %c",unit_letters[next]);
    printw(" LO ");
    if(ifc.lo>=0.0) {
        buf[0]=0;
        dble2str(buf,ifc.lo,-8,1);
        printw("%8s",buf);

        if(1==ifc.sideband)
            printw("%4s"," USB");
        else if(2==ifc.sideband)
            printw("%4s"," LSB");
        else
            printw("%4s"," ");
    } else {
        printw("%8s"," ");
        printw("%4s"," ");
    }

    if(rec && !all)
        printw("%4s"," Rec");
    else if(def && !all)
        printw("%4s"," Def");
    else /* all || !all */
        printw("%4s"," All");

    move(irow++,0);
    printw("Delay");
    buf[0]=0;
    if(UINT_MAX != ifc.delay) {
        uns2str2(buf,ifc.delay,-8,0);
        printw("%8s",buf);
     } else
        printw("%8s"," ");

    printw(" Tsys ");
    if (ifc.lo < 0.0)
        printw("%5s"," ");
    else
        print_tsys(ifc.tsys,ifc.clipped,reverse);

    move(irow++,0);
    printw("Time   ");

/* legitimate times start at the first VDIF epoch */

    if(ifc.time > 0) {
      disp_time=ifc.time+1;
      if(ifc.time_included && tsys_cycle->hsecs < late) {
        disp_time++;
        ifc.time_error++;
      }
      ptr=gmtime(&disp_time);
    }

    if(ifc.time > 0 && NULL != ptr) {
        int tm_different = disp_time!=save_disp_time;

        if(!tm_different && !kfirst)
            standout();

        printw("%4d.%03d.%02d:%02d:%02d",
                ptr->tm_year+1900,
                ptr->tm_yday+1,
                ptr->tm_hour,
                ptr->tm_min,
                ptr->tm_sec);

        if(!tm_different && !kfirst)
            standend();

        save_disp_time=disp_time;
        kfirst = 0;
    } else
       printw("%17s"," ");

    move(irow++,0);
//    printw("Epoch ");
//    if(ifc.time > 0) {
//      if(ifc.vdif_epoch >= 0) {
//        buf[0]=0;
//        int2str(buf,ifc.vdif_epoch,-2,0);
//        printw("%2s",buf);
//      } else
//        printw("%2s","--");
//    } else
//      printw("%2s"," ");

    printw("Arrival ");
    if(ifc.time > 0) {
      if(tsys_cycle->hsecs < late)
        standout();
      buf[0]=0;
      int2str(buf,tsys_cycle->hsecs,-2,0);
      printw("%2s",buf);
      if(tsys_cycle->hsecs < late)
        standend();
    } else
      printw("%2s"," ");

    printw(" DBBC3-FS ");
    if(ifc.time> 0) {
        if (!ifc.time_included)
            printw("------");
        else {
            buf[0]=0;
            int2str(buf,ifc.time_error,-4,0);
            if(ifc.time_error)
                standout();
            printw("%4s",buf);
            if(ifc.time_error)
                standend();
        }
    } else
        printw("%4s"," ");

    move(irow,0);
    if(ifc.lo>=0.0 && krf)
        printw("BBC    RF     Ts-L  Ts-U");
    else
        printw("BBC    IF     Ts-L  Ts-U");

    move(irow++,9);
    if(ifc.lo>=0.0)
        if(ifc.pol==1)
            printw("(R)");
        else if(ifc.pol==2)
            printw("(L)");
        else
            printw("   ");
    else
         printw("   ");

    int itpis[MAX_DBBC3_DET] = {};
    mk5dbbc3d(itpis);

    int swap=krf && 2==ifc.sideband ? 1 : 0;

    for(i=0;i<fs->dbbc3_ddc_bbcs_per_if;i++) {
        int ibbc =next*8+i;
        if(i>=8)
            ibbc=next*8+64+i-8;
        move(irow+i,0);
        printw("%03d",ibbc+1);
        if(bbc[ibbc].freq!=UINT_MAX) {
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

        if (all && (def || rec) || !rec && ifc.lo>=0.0 || itpis[ibbc+swap*MAX_DBBC3_BBC]) {
            printw(" ");
            if(!swap)
              print_tsys(bbc[ibbc].tsys_lsb,bbc[ibbc].clipped_lsb,reverse);
            else
              print_tsys(bbc[ibbc].tsys_usb,bbc[ibbc].clipped_usb,reverse);
        } else
            printw(" %5s"," ");

        if(all && (def || rec) || !rec && ifc.lo>=0.0 || itpis[ibbc+(1-swap)*MAX_DBBC3_BBC]) {
            printw(" ");
            if(!swap)
              print_tsys(bbc[ibbc].tsys_usb,bbc[ibbc].clipped_usb,reverse);
            else
              print_tsys(bbc[ibbc].tsys_lsb,bbc[ibbc].clipped_lsb,reverse);
        } else
            printw(" %5s"," ");
    }
}
