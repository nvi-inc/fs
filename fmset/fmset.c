/* fmset.c - set formatter time when there aren't any buttons */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"  /* module mnemonics */
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "fmset.h"

#define ESC_KEY		0x1b
#define INC_KEY		'+'
#define DEC_KEY		'-'
#define SET_KEY		'='
#define EQ_KEY          '.'
#define TOGGLE_KEY      't'
#define TOGGLE2_KEY     'T'
#define SYNCH_KEY       's'
#define SYNCH2_KEY      'S'

/* externals */
void initvstr();
void getfmtime();
void setfmtime();
void setup_ids();
time_t	asktime(); /* ask operator to enter a time */

/* global variables */
int rack;
int drive;
int source;
unsigned char inbuf[512];      /* class i-o buffer */
unsigned char outbuf[512];     /* class i-o buffer */
long ip[5];           /* parameters for fs communications */
long inclass;         /* input class number */
long outclass;        /* output class number */
int rtn1, rtn2, msgflg, save; /* unused cls_get args */
int synch=0;
long nanosec=-1;

main()  
{
/* local variable declarations */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
time_t unixtime; /* local computer system time */
int    unixhs;
time_t fstime; /* field systm time */
int    fshs;
time_t formtime; /* formatter time */
int    formhs;
char	buffer[128];
int	running=TRUE;
time_t disptime;
int    disphs;
char   inc;
 int    flag;
struct tm *disptm;
int toggle= FALSE;
int other,temp, irow;


setup_ids();         /* connect to shared memory segment */

if (nsem_test(NSEM_NAME) != 1) {
  printf("Field System not running - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
}

rte_prior(CL_PRIOR); /* set our priority */

rack=shm_addr->equip.rack;
drive=shm_addr->equip.drive;

if (drive==S2) {
  source=S2;
  if(rack & MK3 || rack == 0)
    ;
  else {
    toggle=TRUE;
    other=rack;
  }
} else if (rack & MK3 || rack == 0) {
  if(rack & MK3)
    printf("fmset does not support Mark 3 racks - fmset aborting\n");
  else if(rack == 0)
    printf("fmset requires a VLBA/Mark IV rack or S2 recorder to set - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
} else
  source=rack;

if(rack & VLBA)
  initvstr();

/* initialize terminal settings and curses.h data structures and variables */
initscr ();
maindisp = newwin ( 24, 80, 0, 0 );
cbreak();
nodelay ( maindisp, TRUE );
noecho ();
clear_scrn ( maindisp, 24 );
box ( maindisp, 0, 0 );  /* use default vertical/horizontal lines */

/* build display screen */
build:
if(source == S2)
  mvwaddstr( maindisp, 4, 10, "S2 Recorder" );
else
  mvwaddstr( maindisp, 4, 10, "Formatter" );
mvwaddstr( maindisp, 5, 10, "Field System" );
mvwaddstr( maindisp, 6, 10, "Computer" );
mvwaddstr( maindisp, 2, 23, "fmset - formatter/S2 recorder time set" );
mvwaddstr( maindisp, ROW, 10,
 "Use '+'   to increment formatter time by one second." );
mvwaddstr( maindisp, ROW+1, 10,
 "    '-'   to decrement by one second.");
mvwaddstr( maindisp,  ROW+2, 10, 
 "    '='   to be prompted for a new formatter time." );
mvwaddstr( maindisp, ROW+3, 10, 
 "    '.'   to set formatter time to Field System time.");
irow=4;
if(rack& MK4)
  mvwaddstr( maindisp, ROW+irow++, 10,
	     "    's' or 'S' to SYNCH formatter (rarely needed)");
if(!toggle) {
  mvwaddstr( maindisp, ROW+irow++, 10,
	     "    <esc> to quit: DON'T LEAVE FMSET RUNNING FOR LONG.");
} else {
  mvwaddstr( maindisp, ROW+irow++, 10,
     "    't' or 'T' to toggle between S2 recorder and VLBA formatter.");
  mvwaddstr( maindisp, ROW+irow++, 10,
	     "    <esc> to quit.");
}  

leaveok ( maindisp, FALSE); /* leave cursor in place */
wrefresh ( maindisp );


do 	{

	char fmt[40];

	getfmtime(&unixtime,&unixhs,&fstime, &fshs,
                  &formtime,&formhs); /* get times */

        disptime=formtime;
        disphs=formhs+5;
        if (disphs > 99) {
           disphs-=100;
           disptime++;
        }
          
        sprintf( fmt, "%%H:%%M:%%S.%01d %%Z %%d %%b (Day %%j) %%Y",disphs/10);
        disptm = gmtime(&disptime);
	strftime ( buffer, sizeof(buffer), fmt, disptm );
	mvwaddstr( maindisp, 4, 30, buffer );

        disptime=fstime;
        disphs=fshs+5;
        if (disphs > 99) {
           disphs-=100;
           disptime++;
        }
          
        sprintf( fmt, "%%H:%%M:%%S.%01d %%Z %%d %%b (Day %%j) %%Y",disphs/10);
        disptm = gmtime(&disptime);
	strftime ( buffer, sizeof(buffer), fmt, disptm );
	mvwaddstr( maindisp, 5, 30, buffer );

        disptime=unixtime;
        disphs=unixhs+5;
        if (disphs > 99) {
           disphs-=100;
           disptime++;
        }
          
        sprintf( fmt, "%%H:%%M:%%S.%01d %%Z %%d %%b (Day %%j) %%Y",disphs/10);
        disptm = gmtime(&disptime);
	strftime ( buffer, sizeof(buffer), fmt, disptm );
	mvwaddstr( maindisp, 6, 30, buffer );

	wrefresh ( maindisp );

	while (ERR!=(inc=wgetch( maindisp ))) 
	switch ( inc ) {
	case INC_KEY :  /* Increment seconds */
	  setfmtime(formtime++,1);
	  break;
	case DEC_KEY :  /* Decrement seconds */
	  setfmtime(formtime--,-1);
	  break;
	case SET_KEY :  /* Get time from user */
	  formtime = asktime( maindisp,&flag, formtime);
	  if(flag)
	    setfmtime(formtime,0);
	  break;
	case EQ_KEY :  /* set form time from comp time */
	  setfmtime(formtime=fstime+(fshs+50)/100,0);
	  break;
	case ESC_KEY :  /* ESC character */
	  running = FALSE;
	  break;
	case TOGGLE_KEY:
	case TOGGLE2_KEY:
	  if(toggle) {
	    temp=source;
	    source=other;
	    other=temp;
	    goto build;
	  }
	case SYNCH_KEY:
	case SYNCH2_KEY:
	  synch=1;
	  break;
	default     :
			running = TRUE;
	}

} while ( running );

endwin ();
exit(0);

}
