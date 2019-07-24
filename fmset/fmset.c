/* fmset.c - set formatter time when there aren't any buttons */

#include <curses.h>      /* ETI curses standard I/O header file */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"  /* module mnemonics */
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define DISP_BORDER	1
#define DISP_TEXT	2
#define	DISP_FIELDS	3
#define	DISP_ERROR	4

#define ESC_KEY		0x1b
#define INC_KEY		'+'
#define DEC_KEY		'-'
#define SET_KEY		'='
#define EQ_KEY          '.'

/* externals */
void initvstr();
void getfmtime();
void setfmtime();
void setup_ids();
time_t	asktime(); /* ask operator to enter a time */

/* global variables */
int rack;
unsigned char inbuf[512];      /* class i-o buffer */
unsigned char outbuf[512];     /* class i-o buffer */
long ip[5];           /* parameters for fs communications */
long inclass;         /* input class number */
long outclass;        /* output class number */
int rtn1, rtn2, msgflg, save; /* unused cls_get args */

main()  
{
/* local variable declarations */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
time_t unixtime; /* local computer system time */
int    unixhs;
time_t formtime; /* vlba formatter time */
int    formhs;
char	buffer[128];
int	running=TRUE;
time_t disptime;
int    disphs;
char   inc;
int    flag;

/* connect to shared memory segment */
setup_ids();

rack=shm_addr->equip.rack;

if(rack & VLBA)
	initvstr();

/* initialize terminal settings and curses.h data structures and variables */
initscr ();
if ( start_color () == ERR ) {
  init_pair ( DISP_BORDER, COLOR_WHITE, COLOR_BLACK );
  init_pair ( DISP_TEXT,   COLOR_WHITE, COLOR_BLACK );
  init_pair ( DISP_FIELDS, COLOR_WHITE, COLOR_BLACK );
  init_pair ( DISP_ERROR,  COLOR_BLACK, COLOR_WHITE );
} else {
  init_pair ( DISP_BORDER, COLOR_CYAN,   COLOR_BLUE );
  init_pair ( DISP_TEXT,   COLOR_WHITE,  COLOR_BLUE );
  init_pair ( DISP_FIELDS, COLOR_YELLOW, COLOR_BLUE );
  init_pair ( DISP_ERROR,  COLOR_RED,    COLOR_BLUE );
}
maindisp = newwin ( 23, 80, 0, 0 );
wattron ( maindisp, COLOR_PAIR ( DISP_BORDER ) );
clear_scrn ( maindisp, 23 );
box ( maindisp, 0, 0 );  /* use default vertical/horizontal lines */

/* build display screen */
wattroff ( maindisp, COLOR_PAIR ( DISP_BORDER ) );
wattron ( maindisp, COLOR_PAIR ( DISP_TEXT ) );
wattron ( maindisp, A_BOLD );
mvwaddstr( maindisp, 4, 10, "Formatter Clock" );
mvwaddstr( maindisp, 5, 10, "Computer Clock" );
mvwaddstr( maindisp, 2, 30, "Current Time" );
mvwaddstr( maindisp, 2, 23, "fmset - formatter time set" );
mvwaddstr( maindisp, 7, 2,
 "Use '+'   to increment formatter time by one second." );
mvwaddstr( maindisp, 8, 2,
 "    '-'   to decrement by one second.");
mvwaddstr( maindisp,  9, 2, 
 "    '='   to be prompted for a new formatter time." );
mvwaddstr( maindisp, 10, 2, 
 "    '.'   to set formatter time to computer time.");
mvwaddstr( maindisp, 11, 2,
 "    <esc> to quit.");
wattroff ( maindisp, COLOR_PAIR ( DISP_TEXT ) );
nodelay ( maindisp, TRUE );
noecho ();
wattron ( maindisp, COLOR_PAIR ( DISP_FIELDS ) );
leaveok ( maindisp, TRUE); /* leave cursor in place */
wrefresh ( maindisp );


do 	{

	char fmt[40];

	getfmtime(&unixtime,&unixhs,&formtime,&formhs); /* get times */

        disptime=formtime;
        disphs=formhs+5;
        if (disphs > 99) {
           disphs-=100;
           disptime++;
        }
          
        sprintf( fmt, "%%T.%01d %%Z %%d %%b (Day %%j) %%Y",disphs/10);
	cftime ( buffer, fmt, &disptime );
	mvwaddstr( maindisp, 4, 30, buffer );

        disptime=unixtime;
        disphs=unixhs+5;
        if (disphs > 99) {
           disphs-=100;
           disptime++;
        }
          
        sprintf( fmt, "%%T.%01d %%Z %%d %%b (Day %%j) %%Y",disphs/10);
	cftime ( buffer, fmt, &disptime );
	mvwaddstr( maindisp, 5, 30, buffer );

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
			formtime = asktime( maindisp,&flag);
                        if(flag)
                          setfmtime(formtime,0);
			break;
		case EQ_KEY :  /* set form time from comp time */
			setfmtime(formtime=unixtime+(unixhs+50)/100,0);
			break;
		case ESC_KEY :  /* ESC character */
			running = FALSE;
			break;
		default     :
			running = TRUE;
	}

} while ( running );

endwin ();
exit(0);

}
