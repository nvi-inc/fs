#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */
#include <time.h>

#include "fmset.h"

#define ROWA  ROW+6
#define COL0  5 
#define COL   COL0+22

void rte2secs();

extern char *form;

int asksure( maindisp)  /* ask if sure */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
{
char	answer[4];
int kfirst;
int i,j;
char buffer[80];

nodelay ( maindisp, FALSE );
echo ();

 sprintf(buffer, "Are you sure you want to re-synch the %9s (y/n) ?      ",
	 form);
 mvwprintw( maindisp, ROWA+1, COL0, buffer);
	  /* 0123456789012345678901234567890123456789012345678901234567890 */
 mvwscanw(  maindisp, ROWA+1, COL0+56, "%1s", answer );

 nodelay ( maindisp, TRUE );
 noecho ();

 for (i=0; i<2;i++)
   for(j=0;j<78-COL0;j++)
     mvwprintw(maindisp,ROWA+i,COL0+j," ");

 if ( answer[0] != 'Y' && answer[0] != 'y' )
   return( 0 );
 else
   return( 1 );

}
