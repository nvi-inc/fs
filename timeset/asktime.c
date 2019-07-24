#include <curses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */

void rte2secs_();

time_t asktime( maindisp )  /* ask for a time */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
{
int	gotyn = 1, leap = 0,imon = 0,month[13],setyy= -1,setmon= -1,
   setmday = -1,sethh = -1, setmm = -1,setss = -1, yday=0;
char	answer[4];
time_t	ut;
int it[6];

month[0] = 0; month[1] = 31; month[2] = 28; month[3] = 31; month[4] = 30;
month[5] = 31; month[6] = 30; month[7] = 31; month[8] = 31;
month[9] = 30; month[10] = 31; month[11] = 30; month[12] = 31;

nodelay ( maindisp, FALSE );
echo ();

do {

  setyy = -1; setmon = -1; setmday = -1; sethh = -1; setmm = -1; setss = -1;

  while ( setyy > 99 || setyy < 0 ) {  /* prompt for Year */
    mvwprintw( maindisp, 12,  3, "Year   (00-99) ?     " );
    mvwscanw(  maindisp, 12, 20, "%d", &setyy );
  }
  if(setyy % 4 == 0 && setyy != 0) leap = 1;
  month[2] += leap;

  while ( setmon > 12 || setmon < 0 ) {  /* prompt for Month */
    mvwprintw( maindisp, 13,  3, "Month  (01-12) ?     ");
    mvwscanw(  maindisp, 13, 20, "%d", &setmon );
  }

  while ( setmday > month[setmon] || setmday < 0 ) {  /* prompt for Day */
    mvwprintw( maindisp, 14,  3, "Day    (01-%2d) ?     ", month[setmon] );
    mvwscanw( maindisp, 14, 20, "%d", &setmday );
  }
  yday = 0;
  for(imon = 0; imon < setmon; imon++) { yday += month[imon];}
  yday += setmday;

  while ( sethh > 23 || sethh < 0 ) {  /* prompt for Hour */
    mvwprintw( maindisp, 15,  3, "Hour   (00-23) ?     ");
    mvwscanw(  maindisp, 15, 20, "%d", &sethh );
  }

  while ( setmm > 59 || setmm < 0 ) {  /* prompt for Minutes */
    mvwprintw( maindisp, 16,  3, "Minute (00-59) ?     ");
    mvwscanw(  maindisp, 16, 20, "%d", &setmm );
  }

  while ( setss > 59 || setss < 0 ) {  /* prompt for Seconds */
    mvwprintw( maindisp, 17,  3, "Second (00-59) ?     ");
    mvwscanw(  maindisp, 17, 20, "%d", &setss );
  }

  mvwprintw( maindisp, 18,  3,
  "Is (%02d/%02d/%02d)  %02d:%02d:%02d correct (y/n) ?     ",
          setyy, setmon, setmday, sethh, setmm, setss );
  mvwscanw(  maindisp, 18, 43, "%s", answer );
  gotyn = 0;
  if ( answer[0] == 'Y' || answer[0] == 'y' )
    gotyn = 1;

} while ( ! gotyn );

it[0]=0;
it[1]=setss;
it[2]=setmm;
it[3]=sethh;
it[4]=yday;
it[5]=setyy;
rte2secs_(it,&ut);

nodelay ( maindisp, TRUE );
noecho ();
return( ut );

}
