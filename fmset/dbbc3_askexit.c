/*
 * Copyright (c) 2026  NVI, Inc.
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
#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */
#include <time.h>

#include "../include/params.h"

#include "fmset.h"

void rte2secs();

extern char *form;
extern int dbbc;
extern int dbbc_sync;
extern int rack;
extern int source;

int dbbc3_askexit( maindisp,viewed,agree,pps_delay,pps_delay_display,nCore3H)  /* ask if sure */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
int viewed[];
int agree[];
int pps_delay[];
int pps_delay_display;
int nCore3H;
{
    char answer[4];
    int some;
    int i,j;
    int irow=0;
    int ask=0;

    nodelay ( maindisp, FALSE );
    echo ();

    some=0;
    for (i=0;i<nCore3H;i++)
        some=some|| !viewed[i];

    if(some) {
        wstandout(maindisp);
        mvwprintw( maindisp, ROWA+irow, COL0,
                "SOME CORE3H BOARDS WERE NOT VIEWED");
        wstandend(maindisp);
        irow+=2;
        ask=1;
    }

    some=0;
    for (i=0;i<nCore3H;i++)
        some=some|| viewed[i] && !agree[i];

    if(some) {
        wstandout(maindisp);
        mvwprintw( maindisp, ROWA+irow, COL0,
                "SOME CORE3H BOARDS WERE VIEWED BUT HAD A BAD TIME VALUE");
        wstandend(maindisp);
        irow+=2;
        ask=1;
    }

    some=0;
    for (i=0;i<nCore3H;i++)
        some=some|| pps_delay[i]>100;

    if(some) {
        wstandout(maindisp);
        mvwprintw( maindisp, ROWA+irow, COL0,
                "SOME CORE3H BOARDS HAD A LARGE pps_delay VALUE");
        wstandend(maindisp);
        irow+=2;
        ask=1;
    }

    if(!pps_delay_display) {
        wstandout(maindisp);
        mvwprintw( maindisp, ROWA+irow, COL0,
                "FMSET WAS NOT CHECKING PPS_DELAY VALUES WHEN EXITING WAS REQUESTED");
        wstandend(maindisp);
        irow+=2;
        ask=1;
    }

    if(!ask) {
       nodelay ( maindisp, TRUE );
       noecho ();
       return 1;
    }
    mvwprintw( maindisp, ROWA+irow, COL0,
            "Are you sure you want to exit (y/n) ?      ");
         /* 0123456789012345678901234567890123456789012345678901234567890 */
    mvwscanw(  maindisp, ROWA+irow, COL0+39, "%1s", answer );

    nodelay ( maindisp, TRUE );
    noecho ();

    for (i=0; i<7;i++)
        for(j=0;j<78-COL0;j++)
            mvwprintw(maindisp,ROWA+i,COL0+j," ");

    if ( answer[0] != 'Y' && answer[0] != 'y' )
        return( 0 );
    else
        return( 1 );

}
