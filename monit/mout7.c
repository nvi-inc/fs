/*
 * Copyright (c) 2020-2026 NVI, Inc.
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
extern int win_cols;
extern int win_rows;

static char unit_letters[ ] = {"ABCDEFGH"};
static time_t save_disp_time[MAX_DBBC3_IF];
static time_t last_disp_time;

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
static void arrival_age(char buf[128],struct dbbc3_tsys_cycle *tsys_cycle,int age,
   int seconds,time_t time)
{
    printw("Arrival ");
    if(tsys_cycle->no_mcast_since_restart) {
        printw("    ");
    } else {
        if(tsys_cycle->hsecs/100>shm_addr->dbbc3_mcast_arrival/100)
            standout();
        buf[0]=0;
        int2str(buf,tsys_cycle->hsecs,-3,0);
        printw("%2s",buf);
        if(tsys_cycle->hsecs/100>shm_addr->dbbc3_mcast_arrival/100)
            standend();
    }

    printw(" Age");
    if(tsys_cycle->no_mcast_since_restart && time <= 0)
        age=seconds-tsys_cycle->no_mcast_since_restart;
    int hours=age/3600;
    int minutes=age%3600/60;
    int secs=age%3600%60;
    if(hours>=1000)
        snprintf(buf,10,"   >1000h");
    else if(hours>=100)
        snprintf(buf,10," >%3dh%02dm",hours,minutes);
    else if(hours>=1)
        snprintf(buf,10," %2d:%02d:%02d",hours,minutes,secs);
    else if(minutes>=1)
        snprintf(buf,10,"    %2d:%02d",minutes,secs);
    else
        snprintf(buf,10,"       %2d",secs);

    int i;
    for(i=0;i<9;i++) {
        if(buf[i]==' ')
            printw(" ");
        else {
            if(age>shm_addr->dbbc3_mcast_arrival/100)
                standout();
            printw("%s",buf+i);
            break;
        }
    }
    if(age>shm_addr->dbbc3_mcast_arrival/100)
        standend();
}
static void display_version(struct dbbc3_tsys_cycle *tsys_cycle,int ifs_to_display,int it1)
{
    if(!tsys_cycle->no_mcast_since_restart) {
        if( ! tsys_cycle->version_correct && it1%2)
            standout();
        if(ifs_to_display<=2) {
            char temp[sizeof(tsys_cycle->version)];
            memcpy(temp,tsys_cycle->version,sizeof(temp));
            if(strlen(temp)>24)
                strcpy(temp+21,"...");
            printw("%.24s",temp);
        } else if(2<ifs_to_display)
            printw("%.32s",tsys_cycle->version);
        if( ! tsys_cycle->version_correct && it1%2)
            standend();
    } else {
        if(it1%2)
            standout();
//              123456789012345678901234567890
        printw("No multicast data yet.");
        if(it1%2)
            standend();
    }
}
void mout7( int next, struct dbbc3_tsys_cycle *tsys_cycle, int krf, int all,
        int def, int rec, int reverse, int panel, int interleave,
         int bbcs_to_display_per_if0, int ifs_to_display0)
{
    struct dbbc3_tsys_ifc ifc;
    struct dbbc3_tsys_bbc bbc[MAX_DBBC3_BBC];
    char buf[128];
    int i, j, k;
    static time_t disp_time = 0;
    struct tm *ptr;

    int it[6];
    int seconds;
    rte_time(it,it+5);
    rte2secs(it,&seconds);
    seconds-=1;
    int age=seconds-tsys_cycle->last;
    static int interleave_order2[]={0,1};
    static int interleave_order4[]={0,2,1,3};
    static int interleave_order6[]={0,2,4,1,3,5};
    static int interleave_order8[]={0,2,4,6,1,3,5,7};
    static int     normal_order8[]={0,1,2,3,4,5,6,7};
    int *order, count;

    int itpis[MAX_DBBC3_DET] = {};
    mk5dbbc3d(itpis);

    int bbcs_to_display_per_if=0;
    int ifs_to_display=0;
    for (k=0;k<MAX_DBBC3_IF;k++) {
        for (j=0;j<8;j++) {
            if(itpis[ 0+k*8+j              ] ||
               itpis[ 0+k*8+j+MAX_DBBC3_BBC]) {
                ifs_to_display=1+k;
                if( 1+j>bbcs_to_display_per_if)
                  bbcs_to_display_per_if=1+j;
            }
            if(itpis[64+k*8+j              ] ||
               itpis[64+k*8+j+MAX_DBBC3_BBC]) {
                ifs_to_display=1+k;
                if(9+j>bbcs_to_display_per_if)
                  bbcs_to_display_per_if=9+j;
            }
        }
    }

    if(bbcs_to_display_per_if <bbcs_to_display_per_if0)
       bbcs_to_display_per_if=bbcs_to_display_per_if0;
    if(ifs_to_display <ifs_to_display0)
       ifs_to_display=ifs_to_display0;

    int rows_needed_p, cols_needed_p;
    rows_needed_p=2+5+bbcs_to_display_per_if;
    if(ifs_to_display >4 )
        rows_needed_p+=1+5+bbcs_to_display_per_if;
    if(ifs_to_display <=4)
        cols_needed_p=24+25*(ifs_to_display-1);
    else if(ifs_to_display <=6)
        cols_needed_p=24+25*2;
    else
        cols_needed_p=24+25*3;

    int rows_needed_np, cols_needed_np;
    rows_needed_np=1+6+bbcs_to_display_per_if;
    cols_needed_np=24;

    int rows_needed, cols_needed;
    int cols=1;
    int rows=1;
    if(panel) {
        next=0;
        cols=4;
        rows=2;
        if(5==ifs_to_display || 6==ifs_to_display)
          cols=3;
        rows_needed=rows_needed_p;
        cols_needed=cols_needed_p;
        if(!interleave)
             order=    normal_order8;
        else if(2>=ifs_to_display)
             order=interleave_order2;
        else if(4>=ifs_to_display)
             order=interleave_order4;
        else if(6>=ifs_to_display)
             order=interleave_order6;
        else
             order=interleave_order8;
        count=0;
        next=order[count];
    } else {
        rows_needed=rows_needed_np;
        cols_needed=cols_needed_np;
    }

    if(rows_needed >win_rows || cols_needed >win_cols ) {
        move(0,0);
        printw("Window too small.");
        move(2,0);
        printw("Resize to at least:");
        move(3,0);
        printw(" Columns %d Rows %d",cols_needed,rows_needed);
        move(4,0);
        printw(" (.Xresources: %dx%d).",cols_needed,rows_needed);
        move(6,0);
        printw("Current:");
        move(7,0);
        printw(" Columns %d Rows %d.",win_cols,win_rows);
        if(panel && rows_needed_np <= win_rows && cols_needed_np <= win_cols) {
            move(9,0);
            printw("You could use 't' to");
            move(10,0);
            printw(" toggle to non-panel,");
            move(11,0);
            printw(" which will fit.");
        }
        return;
    }

    for(k=0;k<rows;k++) {
        for(j=0;j<cols;j++) {
            int irow=(6+bbcs_to_display_per_if)*k;
            int icol=25*j;
            if(panel)
               irow+=2;
            memcpy(&ifc,&tsys_cycle->ifc[next],sizeof(ifc));
            memcpy(&bbc,tsys_cycle->bbc,sizeof(bbc));
            if(panel && !j && !k) {
                move(0,0);
                arrival_age(buf,tsys_cycle,age,seconds,ifc.time);

                if(1==ifs_to_display)
                    move(1,0);
                else
                    printw(" ");

                display_version(tsys_cycle,ifs_to_display,it[1]);
            }
            move(irow++,icol);
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

            move(irow++,icol);
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

            move(irow++,icol);
            printw("Time   ");

        /* legitimate times start at the first VDIF epoch */

            if(ifc.time > 0) {
              disp_time=ifc.time+1;
              if(ifc.time_error>=-shm_addr->dbbc3_mcast_arrival/100 && ifc.time_error <=0)
                  disp_time-=ifc.time_error;
              if(age <= shm_addr->dbbc3_mcast_arrival/100)
                  disp_time+=age;
              ptr=gmtime(&disp_time);
            }

            if(ifc.time <= 0 || NULL == ptr) {
                printw("%17s"," ");
            } else {
                int time_error=ifc.time_error;
                int tm_bad = time_error<-shm_addr->dbbc3_mcast_arrival/100 || time_error>0;
                tm_bad = tm_bad || age >shm_addr->dbbc3_mcast_arrival/100;

                if(tm_bad)
                    standout();

                printw("%4d.%03d.%02d:%02d:%02d",
                        (ptr->tm_year+1900)%10000,
                        ptr->tm_yday+1,
                        ptr->tm_hour,
                        ptr->tm_min,
                        ptr->tm_sec);

                if(tm_bad)
                    standend();
            }

            move(irow++,icol);
            printw("Epoch ");
            if(!shm_addr->dbbc3_tsys_data.epoch_inserted) {
                printw("%3s","---");
            } else if(tsys_cycle->no_mcast_since_restart) {
                printw("%3s"," ");
            } else {
                buf[0]=0;
                int2str(buf,ifc.vdif_epoch,-3,0);
                printw("%3s",buf);
            }

            printw(" DBBC3-FS ");
            if (!ifc.time_included) {
                printw("-----");
            } else if(tsys_cycle->no_mcast_since_restart || ifc.time <= 0) {
                printw("%5s"," ");
            } else {
                int time_error=ifc.time_error;
                int tm_bad = time_error<-shm_addr->dbbc3_mcast_arrival/100 || time_error>0;
                if(time_error>=-shm_addr->dbbc3_mcast_arrival/100 && time_error<0)
                    time_error=0;
                buf[0]=0;
                int2str(buf,time_error,-5,0);
                for(i=0;i<strlen(buf);i++) {
                    if(buf[i]==' ')
                        printw(" ");
                    else {
                        if(tm_bad)
                            standout();
                        printw("%s",buf+i);
                        break;
                    }
                }
                if(tm_bad)
                    standend();
            }

            if(!panel) {
                move(irow++,icol);
                arrival_age(buf,tsys_cycle,age,seconds,ifc.time);
                move(irow++,icol);
                display_version(tsys_cycle,1,it[1]);
            }

            int swap;

            move(irow,icol);
            if(tsys_cycle->no_mcast_since_restart)
                printw("BBC           Ts-L  Ts-U");
            else if(ifc.lo>=0.0 && krf) {
                printw("BBC    RF     Ts-L  Ts-U");
                swap=2==ifc.sideband ? 1 : 0;
            } else {
                printw("BBC    IF     Ts-L  Ts-U");
                swap=0;
            }

            move(irow++,icol+9);
            if(tsys_cycle->no_mcast_since_restart || ifc.lo<0.0)
                printw("   ");
            else {
                if(ifc.pol==1)
                    printw("(R)");
                else if(ifc.pol==2)
                    printw("(L)");
                else
                    printw("   ");
            }

            for(i=0;i<bbcs_to_display_per_if;i++) {
                int ibbc =next*8+i;
                if(i>=8)
                    ibbc=next*8+64+i-8;
                move(irow+i,icol);
                printw("%03d",ibbc+1);
                if(tsys_cycle->no_mcast_since_restart)
                     continue;
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

                if (all && (def || rec) || !rec && ifc.lo>=0.0 || itpis[ibbc+    swap*MAX_DBBC3_BBC]) {
                    printw(" ");
                    if(!swap)
                      print_tsys(bbc[ibbc].tsys_lsb,bbc[ibbc].clipped_lsb,reverse);
                    else
                      print_tsys(bbc[ibbc].tsys_usb,bbc[ibbc].clipped_usb,reverse);
                } else
                    printw(" %5s"," ");

                if (all && (def || rec) || !rec && ifc.lo>=0.0 || itpis[ibbc+(1-swap)*MAX_DBBC3_BBC]) {
                    printw(" ");
                    if(!swap)
                      print_tsys(bbc[ibbc].tsys_usb,bbc[ibbc].clipped_usb,reverse);
                    else
                      print_tsys(bbc[ibbc].tsys_lsb,bbc[ibbc].clipped_lsb,reverse);
                } else
                    printw(" %5s"," ");
            }
            if(panel) {
                if(++count>ifs_to_display-1)
                  return;
                next=order[count];
            }
        }
    }
}
