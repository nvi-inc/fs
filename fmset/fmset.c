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
int  s2type=0;
char s2dev[2][3] = {"r1","da"};

unsigned char inbuf[512];      /* class i-o buffer */
unsigned char outbuf[512];     /* class i-o buffer */
long ip[5];           /* parameters for fs communications */
long inclass;         /* input class number */
long outclass;        /* output class number */
int rtn1, rtn2, msgflg, save; /* unused cls_get args */
int synch=0;
long nanosec=-1;
static long ipr[5] = { 0, 0, 0, 0, 0};

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
int changedfm=0;
 int changeds2das=0;
 char *ntp;
 int intp;
 char *model;
 long epoch;
 int index,icomputer;

 putpname("fmset");
setup_ids();         /* connect to shared memory segment */

if (nsem_test(NSEM_NAME) != 1) {
  fprintf(stderr,"Field System not running - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
}

if ( 1 == nsem_take("fmset",1)) {
  fprintf( stderr,"fmset already running\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
}

rte_prior(CL_PRIOR); /* set our priority */

rack=shm_addr->equip.rack;
drive=shm_addr->equip.drive[0];

if (drive==S2) {
  source=S2;
  if(rack & MK3 || rack == 0||rack==LBA)
    ;
  else {
    toggle=TRUE;
    other=rack;
  }
} else if (rack & MK3 || rack==0||rack==LBA) {
  if(rack & MK3)
    fprintf(stderr,"fmset does not support Mark 3 racks - fmset aborting\n");
  else if(rack & LBA)
    fprintf(stderr,"fmset does not support LBA racks - fmset aborting\n");
  else
    fprintf(stderr,
	    "fmset requires a VLBA/VLBA4/Mark IV/LBA4/S2 rack or S2 RT to set - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
} else {
  source=rack;
  if(source==S2)
    s2type=1;
}

if(rack & VLBA)
  initvstr();

/* initialize terminal settings and curses.h data structures and variables */
initscr ();
maindisp = newwin ( 24, 80, 0, 0 );
cbreak();
nodelay ( maindisp, TRUE );
noecho ();
curs_set(0);
wclear(maindisp);
wrefresh(maindisp);
box ( maindisp, 0, 0 );  /* use default vertical/horizontal lines */

/* build display screen */
build:
mvwaddstr( maindisp, 2, 23, "fmset - formatter/S2-DAS/S2-RT time set" );
if(source == S2)
   mvwaddstr( maindisp, 4, 10, s2type ? "S2 DAS     " : "S2 RT      " );
else
  mvwaddstr( maindisp, 4, 10, "Formatter  " );
mvwaddstr( maindisp, 5, 10, "Field System" );
mvwaddstr( maindisp, 6, 10, "Computer" );
mvwaddstr( maindisp, ROW, 10,
 "Use '+'     to increment formatter time by one second." );
mvwaddstr( maindisp, ROW+1, 10,
 "    '-'     to decrement formatter time by one second." );
mvwaddstr( maindisp, ROW+2, 10, 
 "    '='     to be prompted for a new formatter time." );
mvwaddstr( maindisp, ROW+3, 10,
 "    '.'     to set formatter time to Field System time.");

irow=4;
 if(source != S2 && (rack& MK4 || rack &VLBA4))
  mvwaddstr( maindisp, ROW+irow++, 10,
 "    's'/'S' to SYNC formatter (VERY rarely needed)");
if(toggle) {
  mvwaddstr( maindisp, ROW+irow++, 10,
 "    't'/'T' to toggle between S2 RT or MarkIV/VLBA formatter/S2 DAS.");
}

 mvwaddstr( maindisp, ROW+irow++, 10,
	    "    <esc>   to quit: DON'T LEAVE FMSET RUNNING FOR LONG.");

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
          
	if(disptime>=0) {
	  sprintf(fmt,
		  "%%H:%%M:%%S.%01d UT  %%d %%b (Day %%j) %%Y",disphs/10);
	  disptm = gmtime(&disptime);
	  strftime ( buffer, sizeof(buffer), fmt, disptm );
	  mvwaddstr( maindisp, 4, 25, buffer );
	} else                      /* 123456789012345678901234567890123456*/
	  mvwaddstr( maindisp, 4, 25, "Year out of range: [1970 to 2037]   ");

	index=01 & shm_addr->time.index;
	epoch=shm_addr->time.epoch[index];
	icomputer=shm_addr->time.icomputer[index];
	if(shm_addr->time.model == 'c'||epoch==0 || icomputer!=0) {
	  fstime=unixtime;
	  fshs=unixhs;
	}

        disptime=fstime;
        disphs=fshs+5;

        if (disphs > 99) {
           disphs-=100;
           disptime++;
        }
 
	if(shm_addr->time.model == 'c'||epoch==0||icomputer!=0)
	  model="computer";
	else if(shm_addr->time.model=='n')
	  model="none    ";
	else if(shm_addr->time.model=='o')
	  model="offset  ";
	else if(shm_addr->time.model=='r')
	  model="rate    ";
	else
	  model="unknown ";
	    
        sprintf( fmt, "%%H:%%M:%%S.%01d UT  %%d %%b (Day %%j) %%Y model: %s",
		 disphs/10,model);
        disptm = gmtime(&disptime);
	strftime ( buffer, sizeof(buffer), fmt, disptm );
	mvwaddstr( maindisp, 5, 25, buffer );

	disptime=unixtime;
	disphs=unixhs+5;
	if (disphs > 99) {
	  disphs-=100;
	  disptime++;
	}

	intp=ntp_synch(0);
	if(intp==1)
	  ntp="sync'd    ";
	else if(intp==0)
	  ntp="not sync'd";
	else
	  ntp="unknown   ";
	
	sprintf(fmt,
		"%%H:%%M:%%S.%01d %%Z %%d %%b (Day %%j) %%Y NTP: %s",
		disphs/10, ntp);
	disptm = gmtime(&disptime);
	strftime ( buffer, sizeof(buffer), fmt, disptm );
	mvwaddstr( maindisp, 6, 25, buffer );

	wrefresh ( maindisp );

	while (ERR!=(inc=wgetch( maindisp ))) 
	switch ( inc ) {
	case INC_KEY :  /* Increment seconds */
	  setfmtime(formtime++,1);
	  if(source == S2 && s2type == 1)
	    changeds2das=1;
	  else
	    changedfm=1;
	  break;
	case DEC_KEY :  /* Decrement seconds */
	  setfmtime(formtime--,-1);
	  if(source == S2 && s2type == 1)
	    changeds2das=1;
	  else
	    changedfm=1;
	  break;
	case SET_KEY :  /* Get time from user */
	  formtime = asktime( maindisp,&flag, formtime);
	  if(flag) {
	    setfmtime(formtime,0);
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  break;
	case EQ_KEY :  /* set form time to fs time */
	  setfmtime(formtime=fstime+(fshs+50)/100,0);
	  if(source == S2 && s2type == 1)
	    changeds2das=1;
	  else
	    changedfm=1;
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
            s2type = 1-s2type;
	    goto build;
	  }
	case SYNCH_KEY:
	case SYNCH2_KEY:
	  if( (rack& MK4 || rack &VLBA4) && asksure( maindisp)) {
	    synch=1;
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  break;
	default:
	  running = TRUE;
	}

} while ( running );

endwin ();
 if(changedfm) {
   logit("Formatter time reset.",0,NULL);
   if(shm_addr->time.model != 'c' && shm_addr->time.model!='n'
      && shm_addr->time.icomputer[01 & shm_addr->time.index]==0)
     skd_run_arg("setcl",' ',ipr,"setcl offset");
   else
     skd_run_arg("setcl",' ',ipr,"setcl");
 }
 if(changeds2das) {
   logit("S2DAS time reset.",0,NULL);
   skd_run_arg("setcl",' ',ipr,"setcl s2das");
 }
exit(0);

}
