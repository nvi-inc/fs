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


int dbbc3_help( maindisp,start_row)
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
int start_row;
{
    char answer[4];
    int i,j;
    int irow=0;

    nodelay ( maindisp, FALSE );

    mvwprintw( maindisp, start_row+irow++, COL0,
            "When fmset starts for a DBBC3, it enters pps_delay display mode");
         /* 0123456789012345678901234567890123456789012345678901234567890 */
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  If any of the pps_delays are not small (<100 ns), use 's' to sync");
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  After a sync, fmset will wait 30 seconds to let the DBBC3 settle");
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  When the pps_delays are all small, use 'z' to enter time display mode");
    irow++;
    mvwprintw( maindisp, start_row+irow++, COL0,
            "In time display mode, use '.=+-' to change board times as needed");
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  Use '.=' to set the time approximately, '+-' to fine tune");
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  Use 'n' to advance to the next board");

    irow++;
    mvwprintw( maindisp, start_row+irow++, COL0,
            "When all boards have the correct time, fmset returns to pps_delays");
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  If the pps_delays are still small, use <esc> to exit");
    mvwprintw( maindisp, start_row+irow++, COL0,
            "  If not, use 's' to sync again and repeat the process");

    irow++;
    mvwprintw( maindisp, start_row+irow++, COL0,
           "BE PATIENT: Interaction with the DBBC3 is slow");
    mvwprintw( maindisp, start_row+irow++, COL0,
           "  Don't enter another command until the display starts updating again");
    mvwprintw( maindisp, start_row+irow++, COL0,
           "  Input commands may be lost due to race conditions, if so try again");
    mvwprintw( maindisp, start_row+irow++, COL0,
           "  '.=+-' commands take 5+ seconds and may not work, if so try again");

    irow++;
    mvwprintw( maindisp, start_row+irow, COL0,
            "Press Enter (return) to leave the fmset DBBC3 help page:      ");
         /* 0123456789012345678901234567890123456789012345678901234567890 */
    mvwscanw(  maindisp, start_row+irow++, COL0+58, "%1s", answer );

    nodelay ( maindisp, TRUE );

    for (i=0; i<irow;i++)
        for(j=0;j<78-COL0;j++)
            mvwprintw(maindisp,start_row+i,COL0+j," ");
}
