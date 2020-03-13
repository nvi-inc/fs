/*
 * Copyright (c) 2020 NVI, Inc.
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

int asksure( maindisp,m5rec,sync)  /* ask if sure */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
int m5rec;
int sync;
{
  char	answer[4], answer2[4];
int kfirst;
int i,j;
char buffer[80];

nodelay ( maindisp, FALSE );
echo ();

 if( sync) {
 sprintf(buffer,
	 "Are you sure you want to sync the %9s (y/n) ?      ",
       /* 0123456789012345678901234567890123456789012345678901234567890 */
	 form);
 mvwprintw( maindisp, ROWA+1, COL0, buffer);
 mvwscanw(  maindisp, ROWA+1, COL0+52, "%1s", answer );
 }
 if ( m5rec && (answer[0] == 'Y' || answer[0] == 'y' || !sync)) {
   if(sync)
     sprintf(buffer,
"The recorder is recording. Sync-ing while recording is not recommended.");
   else
     sprintf(buffer,
"The recorder is recording. Setting the time while recording is not recommended.");
   mvwprintw( maindisp, ROWA+3, COL0, buffer);
   if (sync)
   sprintf(buffer,
    "Are you *REALLY* sure you want to sync (y/n) ?       ");
  /* 0123456789012345678901234567890123456789012345678901234567890 */
   else
   sprintf(buffer,
    "Are you *REALLY* sure you want to set the time (y/n) ?       ");
  /* 0123456789012345678901234567890123456789012345678901234567890 */
 mvwprintw( maindisp, ROWA+4, COL0, buffer);
 if(sync)
 mvwscanw(  maindisp, ROWA+4, COL0+47, "%1s", answer );
 else
 mvwscanw(  maindisp, ROWA+4, COL0+55, "%1s", answer );
 }

 if ( source == DBBC && sync && (answer[0] == 'Y' || answer[0] == 'y') ) {
 sprintf(buffer,
	 "Do you also want to sync the DBBC first (recommended) (y/n) ?      ");
       /* 012345678901234567890123456789012345678901234567890123456789012 */
 mvwprintw( maindisp, ROWA+6, COL0, buffer);
 mvwscanw(  maindisp, ROWA+6, COL0+62, "%1s", answer2 );
 dbbc_sync= answer2[0] == 'Y' || answer2[0] == 'y';
 }

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
