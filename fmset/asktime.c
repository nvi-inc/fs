#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <sys/types.h>   /* data type definition header file */
#include <time.h>

#include "../include/params.h"

#include "fmset.h"

extern int rack;
extern rack_type;

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
int fila10g;

month[0] = 365; month[1] = 31; month[2] = 28; month[3] = 31; month[4] = 30;
month[5] = 31; month[6] = 30; month[7] = 31; month[8] = 31;
month[9] = 30; month[10] = 31; month[11] = 30; month[12] = 31;

nodelay ( maindisp, FALSE );
echo ();

  *flag = FALSE;
  fila10g = rack == DBBC && rack_type == FILA10G;

  tp = gmtime( &ut);

  if (fila10g)
    mvwprintw( maindisp, ROWA, COL0,
	       "If your FiLa10G has GPS, you can use year -1 for GPS time.");

  mvwprintw( maindisp, ROWA+1, COL0,
    "Press <return> to keep present value. Use month 0 for day of year.");

  kfirst = TRUE;
  while ( kfirst ||
	  ((setyy <1970 ||setyy >2037) && !fila10g)||
	  (((setyy !=-1 && setyy <1970) ||setyy >2037) && fila10g)
	  ) {  /* prompt for Year */
    setyy = 1900+tp->tm_year;
    mvwprintw( maindisp, ROWA+2, COL0, "Year   (1970-2037)  ?       " );
    mvwscanw(  maindisp, ROWA+2, COL, "%d", &setyy ); 
    kfirst = FALSE;
  }
  if (fila10g && setyy < 0) {
    ut=-1;
    *flag=TRUE;
    goto End;
  }

  /* not Y2.1K compliant */
  if(setyy % 4 == 0) {
    month[0] = 366;
    month[2] =  29;
  } else {
    month[0] = 365;
    month[2] =  28;
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

  /* not Y10K compliant */
  mvwprintw( maindisp, ROWA+8, COL0,
  "Is (%04d/%02d/%02d)  %02d:%02d:%02d correct (y/n) ?     ",
          setyy, setmon, setmday, sethh, setmm, setss );
  /* not Y10K compliant */
  mvwscanw(  maindisp, ROWA+8, COL0+42, "%1s", answer );
  if ( answer[0] != 'Y' && answer[0] != 'y' )
     goto End;


it[0]=0;
it[1]=setss;
it[2]=setmm;
it[3]=sethh;
it[4]=yday;
it[5]=setyy;
  /* not Y2038 compliant */
rte2secs(it,&ut);
if(ut >= 0)
  *flag=TRUE;

End:
nodelay ( maindisp, TRUE );
noecho ();

for (i=0; i<9;i++)
   for(j=0;j<78-COL0;j++)
      mvwprintw(maindisp,ROWA+i,COL0+j," ");

return( ut );

}
