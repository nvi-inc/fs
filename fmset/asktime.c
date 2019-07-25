#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */
#include <time.h>

#include "fmset.h"

#define ROWA  ROW+6
#define COL0  5 
#define COL   COL0+18

void rte2secs();

time_t asktime( maindisp, flag, ut)  /* ask for a time */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
int *flag;
time_t	ut;
{
int	gotyn, leap,imon,month[13],setyy,setmon;
int     setmday,sethh, setmm,setss, yday;
char	answer[4];
int it[6];
int kfirst;
int i,j;
struct tm *tp;

month[0] = 365; month[1] = 31; month[2] = 28; month[3] = 31; month[4] = 30;
month[5] = 31; month[6] = 30; month[7] = 31; month[8] = 31;
month[9] = 30; month[10] = 31; month[11] = 30; month[12] = 31;

nodelay ( maindisp, FALSE );
echo ();

  *flag = FALSE;
  tp = gmtime( &ut);
  mvwprintw( maindisp, ROWA+0, COL0,
    "Press <return> to keep present value. Use month 0 for day of year.");

  kfirst = TRUE;
  while ( kfirst || setyy > 99 || setyy < 0 ) {  /* prompt for Year */
    setyy = tp->tm_year;
    mvwprintw( maindisp, ROWA+2, COL0, "Year   (00-99)  ?     " );
    mvwscanw(  maindisp, ROWA+2, COL, "%d", &setyy );
    kfirst = FALSE;
  }
  if(setyy % 4 == 0 && setyy != 0) {
    month[0] = 366;
    month[2] =  29;
  }

  kfirst = TRUE;
  while ( kfirst || setmon > 12 || setmon < 0 ) {  /* prompt for Month */
    setmon = tp->tm_mon+1;
    mvwprintw( maindisp, ROWA+3, COL0, "Month  (00-12)  ?     ");
    mvwscanw(  maindisp, ROWA+3, COL, "%d", &setmon );
    kfirst = FALSE;
  }
                                                         /* prompt for Day */
  kfirst = TRUE;
  while ( kfirst || setmday > month[setmon] || setmday <= 0 ) {  
    if(setmon == 0) {
       mvwprintw( maindisp, ROWA+4, COL0,
                 "Day    (01-%3d) ?     ", month[setmon] );
       setmday = tp->tm_yday+1;
    } else {
       mvwprintw( maindisp, ROWA+4, COL0,
                 "Day    (01-%2d)  ?     ", month[setmon] );
       setmday = tp->tm_mday;
    }
    mvwscanw( maindisp, ROWA+4, COL, "%d", &setmday );
    kfirst = FALSE;
  }
  yday = 0;
  for(imon = 1; imon < setmon; imon++)
     yday += month[imon];
  yday += setmday;

  kfirst = TRUE;
  while ( kfirst || sethh > 23 || sethh < 0 ) {  /* prompt for Hour */
    sethh = tp->tm_hour;
    mvwprintw( maindisp, ROWA+5, COL0, "Hour   (00-23)  ?     ");
    mvwscanw(  maindisp, ROWA+5, COL, "%d", &sethh );
    kfirst = FALSE;
  }

  kfirst = TRUE;
  while ( kfirst || setmm > 59 || setmm < 0 ) {  /* prompt for Minutes */
    setmm = tp->tm_min;
    mvwprintw( maindisp, ROWA+6, COL0, "Minute (00-59)  ?     ");
    mvwscanw(  maindisp, ROWA+6, COL, "%d", &setmm );
    kfirst = FALSE;
  }

  kfirst = TRUE;
  while ( kfirst || setss > 59 || setss < 0 ) {  /* prompt for Seconds */
    setss = tp->tm_sec;
    mvwprintw( maindisp, ROWA+7, COL0, "Second (00-59)  ?     ");
    mvwscanw(  maindisp, ROWA+7, COL, "%d", &setss );
    kfirst = FALSE;
  }

  mvwprintw( maindisp, ROWA+8, COL0,
  "Is (%02d/%02d/%02d)  %02d:%02d:%02d correct (y/n) ?     ",
          setyy, setmon, setmday, sethh, setmm, setss );
  mvwscanw(  maindisp, ROWA+8, COL0+40, "%s", answer );
  if ( answer[0] != 'Y' && answer[0] != 'y' )
     goto End;


it[0]=0;
it[1]=setss;
it[2]=setmm;
it[3]=sethh;
it[4]=yday;
it[5]=1900+setyy;
rte2secs(it,&ut);
*flag=TRUE;

End:
nodelay ( maindisp, TRUE );
noecho ();

for (i=0; i<9;i++)
   for(j=0;j<78-COL0;j++)
      mvwprintw(maindisp,ROWA+i,COL0+j," ");

return( ut );

}
