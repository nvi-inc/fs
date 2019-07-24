#define PROGRAM		"timeset"
#define	MODULE		"VLBA Formatter time set"
#define	VERSION		"1.0"
#define	OWNER		"Interferometrics, Inc."
#define COPYRIGHT	"1992"

/*==============================================================( #include )==*/

#include <curses.h>      /* ETI curses standard I/O header file */
#include <errno.h>       /* error code definition header file */
#include <fcntl.h>
#include <memory.h>      /* for memcpy */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"  /* module mnemonics */

/*===============================================================( #define )==*/

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
void skd_run();
time_t getfmtime();
time_t fdate();
void setfmtime();
void initfmtr();
long fjuldat();
void cls_snd();
int cls_rcv();
void cls_clr();
void setup_ids();

/* global variables */
long ip[5];           /* parameters for fs communications */
long inclass;         /* input class number */
long outclass;        /* output class number */
int rtn1, rtn2, msgflg, save; /* unused cls_get args */
unsigned char inbuf[512];      /* class i-o buffer */
unsigned char outbuf[512];     /* class i-o buffer */
char timecmd[] = {5,'f','m',0x00,0x28, /* time years */
                  5,'f','m',0x00,0x29, /* time days  */
                  5,'f','m',0x00,0x2a, /* time hours */
                  5,'f','m',0x00,0x2b, /* time minutes and seconds */
                  5,'f','m',0x00,0x28,
                  5,'f','m',0x00,0x29,
                  5,'f','m',0x00,0x2a,
                  5,'f','m',0x00,0x2b};

char setcmd[] =  {0,'f','m',0x00,0xa8,0x00,0x00,  /* time years */
                  0,'f','m',0x00,0xa9,0x00,0x00,  /* time days  */
                  0,'f','m',0x00,0xaa,0x00,0x00,  /* time hours */
                  0,'f','m',0x00,0xab,0x00,0x00}; /* time min, sec */

/* ******************************************************************** */

main()  
{
/* local variable declarations */
WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
time_t	asktime(); /* ask operator to enter a time */
time_t unixtime; /* local computer system time */
time_t formtime; /* vlba formatter time */
char	buffer[128];
int	running=TRUE;

/* initialize command strings with formatter mnemonic */
memcpy (timecmd+ 1, DEV_VFM, 2);
memcpy (timecmd+ 6, DEV_VFM, 2);
memcpy (timecmd+11, DEV_VFM, 2);
memcpy (timecmd+16, DEV_VFM, 2);
memcpy (timecmd+21, DEV_VFM, 2);
memcpy (timecmd+26, DEV_VFM, 2);
memcpy (timecmd+31, DEV_VFM, 2);
memcpy (timecmd+36, DEV_VFM, 2);
memcpy (setcmd+ 1, DEV_VFM, 2);
memcpy (setcmd+ 8, DEV_VFM, 2);
memcpy (setcmd+15, DEV_VFM, 2);
memcpy (setcmd+22, DEV_VFM, 2);

/* connect to shared memory segment */
setup_ids();

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
sprintf ( buffer, "[ %s V%s ]", MODULE, VERSION );
mvwaddstr ( maindisp, 0, (COLS-strlen(buffer))/2, buffer );
sprintf ( buffer, "[ %s Copyright %s ]", OWNER, COPYRIGHT );
mvwaddstr ( maindisp, 22, (COLS-strlen(buffer))/2, buffer );
wattroff ( maindisp, COLOR_PAIR ( DISP_BORDER ) );
wattron ( maindisp, COLOR_PAIR ( DISP_TEXT ) );
wattron ( maindisp, A_BOLD );
mvwaddstr( maindisp, 2, 16, "Computer Clock" );
mvwaddstr( maindisp, 2, 52, "Formatter Clock" );
mvwaddstr( maindisp, 5, 2, "Current Time" );
mvwaddstr( maindisp, 7, 2,
 "Use '+' to increment formatter time by one second," );
mvwaddstr( maindisp, 8, 2,
 "'-' to decrement by one second, and '=' to set a new time." );
mvwaddstr( maindisp,  9, 2, 
 "Use '.' to make formatter time equal computer time.");
mvwaddstr( maindisp, 10, 2, "Use <esc> to quit.");
wattroff ( maindisp, COLOR_PAIR ( DISP_TEXT ) );
nodelay ( maindisp, TRUE );
noecho ();
wattron ( maindisp, COLOR_PAIR ( DISP_FIELDS ) );
leaveok ( maindisp, TRUE); /* leave cursor in place */
wrefresh ( maindisp );

/* call mcbcn to initialize in case the fs is not running */
/* no buffer is returned after initialization */

ip[0] = 0;        /* initialize */
ip[1] = 0;        /* no class number */
ip[2] = 0;        /* no buffer */
ip[3] = 0;
ip[4] = 0;
skd_run("mcbcn",'w',ip);
skd_par(ip);
if (ip[2] < 0)
	{
	endwin();
	printf ("fatal MCBCN error %ld", ip[2] );
	exit(255);
	}

/* initialize the formatter */
initfmtr();

do 	{

	getfmtime(&unixtime,&formtime); /* get times from mcbcn */

	cftime ( buffer, "%T %Z   %d %b %Y", &formtime );
	mvwaddstr( maindisp, 5, 52, buffer );
	cftime ( buffer, "%T %Z   %d %b %Y", &unixtime );
	mvwaddstr( maindisp, 5, 16, buffer );
	wrefresh ( maindisp );

	switch ( wgetch( maindisp ) ) {
		case INC_KEY :  /* Increment seconds */
			formtime++;
			setfmtime(formtime);
			break;
		case DEC_KEY :  /* Decrement seconds */
			formtime--;
			setfmtime(formtime);
			break;
		case SET_KEY :  /* Get time from user */
			formtime = asktime( maindisp );
			setfmtime(formtime);
			break;
		case EQ_KEY :  /* set form time from comp time */
			setfmtime(unixtime);
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

/* ******************************************************************** */

clear_scrn ( maindisp, num_rows )

WINDOW	* maindisp;
int	num_rows;
{
int	i;
char	blank_field[41];

strncpy ( blank_field, "                                        ", 40 );

for ( i = 0 ; i < num_rows-1 ; ++i ) {
  mvwaddstr ( maindisp, i,  0, blank_field );
  mvwaddstr ( maindisp, i, 40, blank_field );
}

}

/* ******************************************************************** */

time_t asktime( maindisp )  /* ask for a time */

WINDOW	* maindisp;  /* main display WINDOW data structure pointer */
{
int	gotyn = 1, leap = 0,imon = 0,month[13],setyy= -1,setmon= -1,
   setmday = -1,sethh = -1, setmm = -1,setss = -1, yday=0;
char	answer[4];
time_t	ut, mktime();
struct	tm *timeptr, *localtime();

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

time( &ut );
timeptr = gmtime( &ut );
timeptr->tm_year = setyy;
timeptr->tm_mon = setmon - 1;  /* mon = 0 -11 */
timeptr->tm_mday = setmday;
timeptr->tm_hour = sethh;
timeptr->tm_min = setmm;
timeptr->tm_sec = setss;
timeptr->tm_isdst = 0;
ut = mktime( timeptr );

nodelay ( maindisp, TRUE );
noecho ();
return( ut );

}

/* ******************************************************************** */

time_t fdate(year,doy,hr,min,sec) /* get unix 'calendar date' from year,doy */
unsigned long year;  /* four digit year */
unsigned long doy;   /* day of year */
unsigned long hr;    /* hour */
unsigned long min;   /* minute */
unsigned long sec;   /* second */

{
unsigned long n1970 = 1970;
unsigned long n1 = 1;

        long seconds; /* number of seconds elapsed since 1 Jan 1970 */

        seconds = 86400L * (fjuldat(n1,doy,year) - fjuldat(n1,n1,n1970));
        seconds += (hr*3600 + min*60 + sec);
        return(seconds);
}

/* ******************************************************************** */

long fjuldat(month,day,year) /* get (julian date-0.5) from month, day, year */
unsigned long month;
unsigned long day;
unsigned long year;

{
        if (year < 1000) year+= 1900;
        return(1721013L + 367*year -(7*(year+(month+9)/12))/4
            +(275*month)/9 + day);
}

/* ******************************************************************** */

time_t getfmtime(unixtime,formtime)
time_t *unixtime; /* system time received from mcbcn */
time_t *formtime; /* formatter time received from mcbcn */

{
        unsigned short fmtyya; /* formatter BCD YYYY */
        unsigned short fmtdda; /* formatter BCD 0DDD */
        unsigned short fmthha; /* formatter BCD 00HH */
        unsigned short fmtmsa; /* formatter BCD MMSS */
        unsigned short fmtyyb; /* formatter BCD YYYY */
        unsigned short fmtddb; /* formatter BCD 0DDD */
        unsigned short fmthhb; /* formatter BCD 00HH */
        unsigned short fmtmsb; /* formatter BCD MMSS */
	int nbytes;            /* bytes received from mcbcn */
        int cnt;               /* counter for the repeat loop */
	int i;                 /* general purpose counter */
        time_t time1;          /* time from the first formatter reading */
        time_t time2;          /* time from the second formatter reading */
        int dt;                /* difference in times */
	unsigned long ly,ld,lh,lm,ls,lmsa,lmsb; /* temporaries */

        dt = 100;
        cnt = 0;
        while ( (dt > 10) && (cnt++ < 5) ) /* iterate until two consecutive */
        {                                  /* readings are about the same   */
	for (i = 0; i < 40; i++)
		{
		outbuf[i] = timecmd[i];
		}

/* create class and send command */
	outclass = 0;
	cls_snd(&outclass, outbuf, 40, 0, 0); 

	ip[0] = 1;        /* process command buf */
	ip[1] = outclass; /* class number */
	ip[2] = 1;        /* only one buf */
	ip[3] = 0;
	ip[4] = 0;
	skd_run("mcbcn",'w',ip);

/* get reply from mcbcn */
	ip[0] = ip[1] = ip[2] = ip[3] = ip[4] = 0;
	skd_par(ip);
	inclass = ip[0];
	if( ip[1] != 1 )
		{
		endwin();
		printf("No reply from formatter - error %d\n", ip[2] );
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}
	if( ip[2] != 2 )
		{
		endwin();
		printf("Error %d from formatter\n",ip[2]);
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}
	msgflg = save = 0;
	if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                               &rtn1, &rtn2, msgflg, save)) != 88)
		{
		endwin();
		printf("Wrong len msg - %d bytes received\n" ,nbytes);
		cls_clr(outclass);
		cls_clr(inclass);
		exit(0);
		}

/* the way mcbcn is written, getting the right length message         */
/* is enough to insure that each of the eight requests was successful */

	cls_clr(outclass); /* clear class numbers just in case */
	cls_clr(inclass);

/* get the two times bracketing the commands with bytes in the right order */
	memcpy ( (char*) &time1, inbuf+ 1, 4);
	memcpy ( (char*) &time2, inbuf+84, 4);
	*unixtime = time1 + (time2-time1)/2;

/* get the various formatter times with bytes in the right order */
	swab ( inbuf+ 5, inbuf+ 5, 2);
	swab ( inbuf+16, inbuf+16, 2);
	swab ( inbuf+27, inbuf+27, 2);
	swab ( inbuf+38, inbuf+38, 2);
	swab ( inbuf+49, inbuf+49, 2);
	swab ( inbuf+60, inbuf+60, 2);
	swab ( inbuf+71, inbuf+71, 2);
	swab ( inbuf+82, inbuf+82, 2);
	memcpy ( (char*) &fmtyya, inbuf+ 5, 2);
	memcpy ( (char*) &fmtdda, inbuf+16, 2);
	memcpy ( (char*) &fmthha, inbuf+27, 2);
	memcpy ( (char*) &fmtmsa, inbuf+38, 2);
	memcpy ( (char*) &fmtyyb, inbuf+49, 2);
	memcpy ( (char*) &fmtddb, inbuf+60, 2);
	memcpy ( (char*) &fmthhb, inbuf+71, 2);
	memcpy ( (char*) &fmtmsb, inbuf+82, 2);

/* convert year from BCD to integer */
        fmtyya = (fmtyya >> 12 & 0xf) * 1000 + (fmtyya >>  8 & 0xf) * 100
                 +(fmtyya >>  4 & 0xf) *   10 + (fmtyya       & 0xf);
        fmtyyb = (fmtyyb >> 12 & 0xf) * 1000 + (fmtyyb >>  8 & 0xf) * 100
                 +(fmtyyb >>  4 & 0xf) *   10 + (fmtyyb       & 0xf);

/* convert day number from BCD to integer */
        fmtdda = (fmtdda >>  8 & 0xf) * 100
                 +(fmtdda >>  4 & 0xf) *   10 + (fmtdda      & 0xf);
        fmtddb = (fmtddb >>  8 & 0xf) * 100
                 +(fmtddb >>  4 & 0xf) *   10 + (fmtddb      & 0xf);

/* convert hours, minutes, and seconds from BCD to integer seconds */
        fmthha = (fmthha >>  4 & 0xf) *   10 + (fmthha      & 0xf);
                 fmthhb = (fmthhb >>  4 & 0xf) *   10 + (fmthhb      & 0xf);
        fmtmsa = (fmtmsa >> 12 & 0xf) *  600 + (fmtmsa >>  8 & 0xf) * 60
                 +(fmtmsa >>  4 & 0xf) *   10 + (fmtmsa       & 0xf);
        fmtmsb = (fmtmsb >> 12 & 0xf) *  600 + (fmtmsb >>  8 & 0xf) * 60
                 +(fmtmsb >>  4 & 0xf) *   10 + (fmtmsb       & 0xf);
        lmsa = fmtmsa + (fmthha*3600);
        lmsb = fmtmsb + (fmthhb*3600);

 /* get time in seconds since 1 Jan 1970 */
	ly = fmtyya;
	ld = fmtdda;
	lh = 0;
	lm = 0;
	ls = 0;
        time1 =  fdate(ly,ld,lh,lm,ls) + lmsa;
	ly = fmtyyb;
	ld = fmtddb;
        time2 =  fdate(ly,ld,lh,lm,ls) + lmsb;
	*formtime = time1 + (time2-time1);
        dt = abs( (double)time2 -  (double)time1);
        }

        if (cnt >= 5) *formtime = 1;
}

/* ******************************************************************** */

void setfmtime(formtime)
time_t formtime;

{
struct tm *fmtime;  /* pointer to tm structure */
int i;              /* general purpose counter */
int nbytes;         /* number of bytes received from mcbcn */
unsigned short bcd; /* holder for BCD digits   */

/* convert calendar time to conventional time */
fmtime = gmtime(&formtime);

for (i = 0; i < 28; i++)  /* get set time message */
	{
	outbuf[i] = setcmd[i];
	}

fmtime->tm_year += 1900;  /* gmtime returns years since 1900 */
bcd = 0;
for (i = 1000; i; i /= 10)
	{
	bcd = (bcd << 4) + fmtime->tm_year / i;
	fmtime->tm_year = fmtime->tm_year % i;
	}
memcpy(outbuf+5,&bcd,2);
swab(outbuf+5,outbuf+5,2);

/* stuff address & BCD day # into message */
fmtime->tm_yday += 1;  /* gmtime returns days since 1 january */
bcd = 0;
for (i = 100; i; i /= 10)
	{
	bcd = (bcd << 4) + fmtime->tm_yday / i;
	fmtime->tm_yday = fmtime->tm_yday % i;
	}
memcpy(outbuf+12,&bcd,2);
swab(outbuf+12,outbuf+12,2);

/* stuff address & BCD hour into message */
bcd = fmtime->tm_hour / 10 << 4 | fmtime->tm_hour % 10;
memcpy(outbuf+19,&bcd,2);
swab(outbuf+19,outbuf+19,2);

/* stuff address & BCD minute-second into message */
bcd = fmtime->tm_min / 10 << 12 |
      fmtime->tm_min % 10 << 8  |
      fmtime->tm_sec / 10 << 4  |
      fmtime->tm_sec % 10;
memcpy(outbuf+26,&bcd,2);
swab(outbuf+26,outbuf+26,2);

/* send request buffer to MCB */
/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, 28, 0, 0); 

ip[0] = 1;        /* process command buf */
ip[1] = outclass; /* class number */
ip[2] = 1;        /* only one buf */
ip[3] = 0;
ip[4] = 0;
skd_run("mcbcn",'w',ip);

/* get reply from mcbcn */
ip[0] = ip[1] = ip[2] = ip[3] = ip[4] = 0;
skd_par(ip);
inclass = ip[0];
if( ip[1] != 1 )
	{
	endwin();
	printf("No reply from formatter - error %d\n", ip[2] );
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}
if( ip[2] != 0 )
	{
	endwin();
	printf("Error %d from formatter\n",ip[2]);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}
msgflg = save = 0;
if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                       &rtn1, &rtn2, msgflg, save)) != 4)
	{
	endwin();
	printf("Wrong len msg - %d bytes received\n" ,nbytes);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}

if( inbuf[0] | inbuf[1] | inbuf[2] | inbuf[3] ) /* check completion code */
	{
	endwin();
	printf("Bad completion code from formatter %d %d %d %d\n",
               inbuf[0],inbuf[1],inbuf[2],inbuf[3]);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}

cls_clr(outclass); /* clear class numbers just in case */
cls_clr(inclass);

}

void initfmtr()

{
int nbytes;  /* number of bytes received */

outbuf[0] = 2;
memcpy (outbuf+1, DEV_VFM, 2);

/* send request buffer to MCB */
/* create class and send command */
outclass = 0;
cls_snd(&outclass, outbuf, 3, 0, 0); 

ip[0] = 1;        /* process command buf */
ip[1] = outclass; /* class number */
ip[2] = 1;        /* only one buf */
ip[3] = 0;
ip[4] = 0;
skd_run("mcbcn",'w',ip);

/* get reply from mcbcn */
ip[0] = ip[1] = ip[2] = ip[3] = ip[4] = 0;
skd_par(ip);
inclass = ip[0];
if( ip[1] != 1 )
	{
	endwin();
	printf("No reply initializing formatter - error %d\n", ip[2] );
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}
if( ip[2] != 0 )
	{
	endwin();
	printf("Error %d from formatter\n",ip[2]);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}
msgflg = save = 0;
if ( (nbytes = cls_rcv(inclass, inbuf, 512, 
                       &rtn1, &rtn2, msgflg, save)) != 1)
	{
	endwin();
	printf("Wrong len msg - %d bytes received\n" ,nbytes);
	cls_clr(outclass);
	cls_clr(inclass);
	exit(0);
	}

cls_clr(outclass); /* clear class numbers just in case */
cls_clr(inclass);

}
