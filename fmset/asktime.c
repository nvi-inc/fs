#include <curses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */

#define ROW   13
#define COL   21

void rte2secs();

time_t asktime( maindisp, flag )  /* ask for a time */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
int *flag;
{
int	gotyn = 1, leap = 0,imon = 0,month[13],setyy= -1,setmon= -1,
   setmday = -1,sethh = -1, setmm = -1,setss = -1, yday=0;
char	answer[4];
time_t	ut;
int it[6];
int kfirst;

month[0] = 365; month[1] = 31; month[2] = 28; month[3] = 31; month[4] = 30;
month[5] = 31; month[6] = 30; month[7] = 31; month[8] = 31;
month[9] = 30; month[10] = 31; month[11] = 30; month[12] = 31;

nodelay ( maindisp, FALSE );
echo ();

  *flag = FALSE;
  setyy = -1; setmon = -1; setmday = -1; sethh = -1; setmm = -1; setss = -1;

  kfirst = TRUE;
  while ( kfirst || setyy > 99 || setyy < 0 ) {  /* prompt for Year */
    mvwprintw( maindisp, ROW+0,  3, "Year   (00-99)  ?     " );
    mvwscanw(  maindisp, ROW+0, COL, "%d", &setyy );
    kfirst = FALSE;
  }
  if(setyy % 4 == 0 && setyy != 0) {
    month[0] = 366;
    month[2] =  29;
  }

  kfirst = TRUE;
  while ( kfirst || setmon > 12 || setmon < 0 ) {  /* prompt for Month */
    mvwprintw( maindisp, ROW+1,  3, "Month  (00-12)  ?     ");
    mvwscanw(  maindisp, ROW+1, COL, "%d", &setmon );
    kfirst = FALSE;
  }
                                                         /* prompt for Day */
  kfirst = TRUE;
  while ( kfirst || setmday > month[setmon] || setmday <= 0 ) {  
    if(setmon == 0)
    mvwprintw( maindisp, ROW+2,  3, "Day    (01-%3d) ?     ", month[setmon] );
    else
    mvwprintw( maindisp, ROW+2,  3, "Day    (01-%2d)  ?     ", month[setmon] );
    mvwscanw( maindisp, ROW+2, COL, "%d", &setmday );
    kfirst = FALSE;
  }
  yday = 0;
  for(imon = 0; imon < setmon; imon++) { yday += month[imon];}
  yday += setmday;

  kfirst = TRUE;
  while ( kfirst || sethh > 23 || sethh < 0 ) {  /* prompt for Hour */
    mvwprintw( maindisp, ROW+3,  3, "Hour   (00-23)  ?     ");
    mvwscanw(  maindisp, ROW+3, COL, "%d", &sethh );
    kfirst = FALSE;
  }

  kfirst = TRUE;
  while ( kfirst || setmm > 59 || setmm < 0 ) {  /* prompt for Minutes */
    mvwprintw( maindisp, ROW+4,  3, "Minute (00-59)  ?     ");
    mvwscanw(  maindisp, ROW+4, COL, "%d", &setmm );
    kfirst = FALSE;
  }

  kfirst = TRUE;
  while ( kfirst || setss > 59 || setss < 0 ) {  /* prompt for Seconds */
    mvwprintw( maindisp, ROW+5,  3, "Second (00-59)  ?     ");
    mvwscanw(  maindisp, ROW+5, COL, "%d", &setss );
    kfirst = FALSE;
  }

  mvwprintw( maindisp, ROW+6,  3,
  "Is (%02d/%02d/%02d)  %02d:%02d:%02d correct (y/n) ?     ",
          setyy, setmon, setmday, sethh, setmm, setss );
  mvwscanw(  maindisp, ROW+6, 43, "%s", answer );
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
return( ut );

}
