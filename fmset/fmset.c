/* fmset.c - set formatter time when there aren't any buttons */

#include <ncurses.h>      /* ETI curses standard I/O header file */
#include <time.h>        /* time function definition header file */
#include <sys/types.h>   /* data type definition header file */
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "../include/params.h"  /* module mnemonics */
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "fmset.h"
#include "fila10g_cfg.h"

#define ESC_KEY		0x1b
#define INC_KEY		'+'
#define DEC_KEY		'-'
#define VDIF_INC_KEY	'>'
#define VDIF_DEC_KEY	'<'
#define VDIF_NOM_KEY	';'
#define SET_KEY		'='
#define EQ_KEY          '.'
#define TOGGLE_KEY      't'
#define TOGGLE2_KEY     'u'
#define SYNCH_KEY       's'
#define SYNCH2_KEY      'S'

/* externals */
void initvstr();
void getfmtime();
void setfmtime();
void setup_ids();
time_t	asktime(); /* ask operator to enter a time */

/* global variables */
int rack, rack_type;
char *form;
int source;
int hint_row;
int  s2type=0;
char s2dev[2][3] = {"r1","da"};
int m5rec;
int m5b_crate;
int dbbcddcv;
struct fila10g_cfg *fila10g_cfg_use = NULL;
struct fila10g_cfg *ask_fila10g_cfg();
int iRDBE;
int iDBBC;

WINDOW	* maindisp;  /* main display WINDOW data structure pointer */

unsigned char inbuf[512];      /* class i-o buffer */
unsigned char outbuf[512];     /* class i-o buffer */
long ip[5];           /* parameters for fs communications */
long inclass;         /* input class number */
long outclass;        /* output class number */
int rtn1, rtn2, msgflg, save; /* unused cls_get args */
int synch=0;
long nanosec=-1;
static long ipr[5] = { 0, 0, 0, 0, 0};
int dbbc_sync=0;

main()  
{
/* local variable declarations */
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
int toggle2= FALSE;
int other,temp, irow;
int changedfm=0;
 int changeds2das=0;
 char *ntp;
 int intp;
 char *model;
 long epoch;
 int index,icomputer;
 int column,i;
char mk5b_sync[13] ="";
char mk5b_1pps[10] ="";
char mk5b_clock_freq[10] ="";
char mk5b_clock_source[10] ="";
char blank[ ] = {"                                                                              "};
int drive, drive_type;
struct fila10g_cfg *fila10g_cfg=NULL;
int ierr;
int nRDBE;
int clear_area=0;
int vdif_epoch, vdif_should;


 putpname("fmset");
skd_set_return_name("fmset");
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

while (skd_clr_ret(ip)) // only one should be possible, but just  in case 
    if(ip[1]!=0)
     cls_clr(ip[0]);
// note that the above will not clear a partially read set of clase buffers
// it only handles if 'fmset' is aborted while a ...cn is running
// so not bullet proof, but more robust

rte_prior(CL_PRIOR); /* set our priority */

rack=shm_addr->equip.rack;
rack_type=shm_addr->equip.rack_type;
drive=shm_addr->equip.drive[0];
drive_type=shm_addr->equip.drive_type[0];
m5b_crate=shm_addr->m5b_crate;
dbbcddcv=shm_addr->dbbcddcv;

 nRDBE=0;
 for(i=0;i<4;i++) 
   if(shm_addr->rdbe_units[i])
     nRDBE++;
 if(shm_addr->rdbe_units[0])
   iRDBE=1;
 else if(shm_addr->rdbe_units[1])
   iRDBE=2;
 else if(shm_addr->rdbe_units[2])
   iRDBE=3;
 else if(shm_addr->rdbe_units[3])
   iRDBE=4;

 if (rack == RDBE) {
   if(nRDBE==0) {
     fprintf(stderr,
	     "no RDBEs available, correct rdbc?.ctl, and restart FS - fmset aborting\n");
     rte_sleep(SLEEP_TIME);
     exit(0);
   }
   source=RDBE;
   if(shm_addr->dbbc_defined || shm_addr->dbbc2_defined) {
     toggle=TRUE;
     other=DBBC;
     if(!shm_addr->dbbc2_defined)
       iDBBC=0;
     else if(shm_addr->dbbc_defined)
       iDBBC=1;
     else
       iDBBC=2;
     if(shm_addr->dbbc_defined && shm_addr->dbbc2_defined)
       toggle2=TRUE;
   }
 } else if( drive==MK5 && (drive_type == MK5B || drive_type == MK5B_BS))
  source=drive;
else if (drive==S2) {
   source=S2;
  if(rack & MK3 || rack == 0||rack==LBA)
    ;
  else {
    toggle=TRUE;
    other=rack;
  }
 } else if (rack==DBBC && (rack_type==DBBC_DDC_FILA10G ||rack_type==DBBC_PFB_FILA10G)) {
  char buff[80];
  strcpy(buff,FS_ROOT);
  strncat(buff,"/control/fila10g_cfg.ctl",sizeof(buff)-strlen(buff)-1);
  if(gfila10g_cfg(buff,&fila10g_cfg)) {
    fprintf( stderr,"fmset: error reading fila10g_cfg.ctl file, see log for error\n");
    rte_sleep(SLEEP_TIME);
    exit(0);
  }
  source=DBBC;
  if(nRDBE!=0) {
    toggle=TRUE;
    other=RDBE;
  }
  if(shm_addr->dbbc_defined || shm_addr->dbbc2_defined) {
     if(!shm_addr->dbbc2_defined)
       iDBBC=0;
     else     if(shm_addr->dbbc_defined)
       iDBBC=1;
     else
      iDBBC=2;
    if(shm_addr->dbbc_defined && shm_addr->dbbc2_defined)
      toggle2=TRUE;
  }

 } else if ((rack & MK3 || rack==0||rack==LBA ||rack==DBBC) ||
	    ((( rack == MK4 && rack_type != MK4) ||
	      (rack == VLBA4 && rack_type != VLBA4)) &&
	     ( drive = MK5 && drive_type != MK5B && drive_type != MK5B_BS))
	    ){
  if(rack & MK3)
    fprintf(stderr,"fmset does not support Mark 3 racks - fmset aborting\n");
  else if(rack & LBA)
    fprintf(stderr,"fmset does not support LBA racks - fmset aborting\n");
  else
    fprintf(stderr,
	    "fmset requires a VLBA/VLBA4/Mark IV/LBA4/S2-DAS/S2-RT/Mark5B/FILA10G or RDBE to set - fmset aborting\n");
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
 if(clear_area) 
   for (i=4;i<hint_row+irow;i++)
     mvwaddstr( maindisp, i, 1, blank);

 clear_area=0;
 column=10;
 hint_row=8;
mvwaddstr( maindisp, 2, 3, "fmset - VLBA & Mark IV formatter/S2-DAS/S2-RT/Mark5B/FiLa10G/RDBE time set" );
 if(source == RDBE) {
   column=6;
   hint_row=10;
   if(1==iRDBE) {
     form="rdbe-A";
     mvwaddstr( maindisp, 4, column, "rdbe-A      " );
   } else if(2==iRDBE) {
     form="rdbe-B";
     mvwaddstr( maindisp, 4, column, "rdbe-B      " );
   } else if(3==iRDBE) {
     form="rdbe-C";
     mvwaddstr( maindisp, 4, column, "rdbe-C      " );
   } else if(4==iRDBE) {
     form="rdbe-D";
     mvwaddstr( maindisp, 4, column, "rdbe-D      " );
   }
 } else if( source == MK5) {
   column=6;
   hint_row=12;
   form="Mark 5B";
  mvwaddstr( maindisp, 4, column, "Mark 5B     " );
 }  else if (source==DBBC 
    /* was:
     * rack==DBBC &&(rack_type==DBBC_DDC_FILA10G ||rack_type==DBBC_PFB_FILA10G) */
	     ) {
   if(0==iDBBC) {
     mvwaddstr( maindisp, 4, column, "FiLa10G     " );
     form="FiLa10G";
   } else if(1==iDBBC) {
     mvwaddstr( maindisp, 4, column, "FiLa10G#1   " );
     form="FiLa10G#1";
   } else {
     mvwaddstr( maindisp, 4, column, "FiLa10G#2   " );
     form="FiLa10G#2";
   }
 } else if(source == S2) {
   mvwaddstr( maindisp, 4, column, s2type ? "S2 DAS      " : "S2 RT       " );
   form=s2type ? "S2 DAS" : "S2 RT ";       
 } else if((rack& MK4 || rack &VLBA4)) {
  mvwaddstr( maindisp, 4, column, "Mark IV FM  " );
  form="formatter";
 } else { 
  mvwaddstr( maindisp, 4, column, "VLBA FM     " );
  form="formatter";
 }
mvwaddstr( maindisp, 5, column,   "Field System" );
mvwaddstr( maindisp, 6, column,   "Computer" );

 sprintf(buffer, "Use '+'     to increment %s time by one second.",form);
   mvwaddstr( maindisp, hint_row, column,buffer);
 sprintf(buffer,"    '-'     to decrement %s time by one second." ,form);
 mvwaddstr( maindisp, hint_row+1, column, buffer);
 sprintf(buffer, "    '='     to be prompted for a new %s time.",form);
 mvwaddstr( maindisp, hint_row+2, column, buffer);
 sprintf(buffer, "    '.'     to set %s time to Field System time.",form);
 mvwaddstr( maindisp, hint_row+3, column, buffer);
 irow=3;
 if(source==RDBE) {
   if(vdif_epoch < vdif_should) {
     sprintf(buffer,"    '>'     to increment %s VDIF epoch." ,form);
     irow++;
   }
   mvwaddstr( maindisp, hint_row+irow++, column, buffer);
   sprintf(buffer,"    '<'     to decrement %s VDIF epoch." ,form);
   mvwaddstr( maindisp, hint_row+irow++, column, buffer);
   sprintf(buffer,"    ';'     to set VDIF epoch to nominal.      " ,form);
   mvwaddstr( maindisp, hint_row+irow++, column, buffer);
 }
 if(source != S2 && (rack& MK4 || rack &VLBA4 || source == MK5 ||
		     source==DBBC 
    /* was:
     * rack==DBBC &&(rack_type==DBBC_DDC_FILA10G ||rack_type==DBBC_PFB_FILA10G) */
		      || source==RDBE)) {
   sprintf(buffer, "    's'/'S' to SYNC %s (VERY rarely needed)",form);
   mvwaddstr( maindisp, hint_row+irow++, column, buffer);
 } 
if(toggle) {
  if(source == S2 || other==S2)
    mvwaddstr( maindisp, hint_row+irow++, column,
 "    't'/'T' to toggle between S2 RT or MarkIV/VLBA formatter/S2 DAS.");
  else
    mvwaddstr( maindisp, hint_row+irow++, column,
 "    't'/'T' to toggle between RDBE or FiLa10G.");
 }
 if(source==DBBC && toggle2)
   mvwaddstr( maindisp, hint_row+irow++, column,
 "    'u'/'U' to toggle between FiL10G#1 or FiLa10G#2.");

if(source == RDBE && nRDBE > 1) {
  if(shm_addr->rdbe_units[0] && 1!=iRDBE)
    mvwaddstr( maindisp, hint_row+irow++, column,
	       "    'a'/'A' to select rdbe-A.");
  if(shm_addr->rdbe_units[1] && 2!=iRDBE)
    mvwaddstr( maindisp, hint_row+irow++, column,
	       "    'b'/'B' to select rdbe-B.");
  if(shm_addr->rdbe_units[2] && 3!=iRDBE)
    mvwaddstr( maindisp, hint_row+irow++, column,
	       "    'c'/'C' to select rdbe-C.");
  if(shm_addr->rdbe_units[3] && 4!=iRDBE)
    mvwaddstr( maindisp, hint_row+irow++, column,
	       "    'd'/'D' to select rdbe-D.");
}

 mvwaddstr( maindisp, hint_row+irow++, column,
	    "    <esc>   to quit: DON'T LEAVE FMSET RUNNING FOR LONG.");

 if(source==RDBE && vdif_epoch == vdif_should)
   mvwaddstr( maindisp, hint_row+irow, 1, blank);

leaveok ( maindisp, FALSE); /* leave cursor in place */
wrefresh ( maindisp );


do 	{

	char fmt[80];

	memset(mk5b_sync,' ',sizeof(mk5b_sync)-1);
	mk5b_sync[sizeof(mk5b_sync)-1]=0;
	getfmtime(&unixtime,&unixhs,&fstime, &fshs,
		  &formtime,&formhs,mk5b_sync,sizeof(mk5b_sync),
		  mk5b_1pps,sizeof(mk5b_1pps),
		  mk5b_clock_freq,sizeof(mk5b_clock_freq),
		  mk5b_clock_source,sizeof(mk5b_clock_source),
		  &vdif_epoch,&ierr); /* get times */

	vdif_should=-1;
	if(formtime>=0) {
	  disptime=formtime;
	  disphs=formhs+5;
	  if (disphs > 99) {
	    disphs-=100;
	    disptime++;
	  }
          if(source!= RDBE)
	    sprintf(fmt,"%%H:%%M:%%S.%01d UT  %%d %%b (Day %%j) %%Y %s   ",
		    disphs/10, mk5b_sync);
	  else
	    sprintf(fmt,"%%H:%%M:%%S.%01d UT  %%d %%b (Day %%j) %%Y VDIF Epoch %d ",
		    disphs/10, vdif_epoch);
	  disptm = gmtime(&disptime);
	  strftime ( buffer, sizeof(buffer), fmt, disptm );
	  mvwaddstr( maindisp, 4, column+15, buffer );
	  for(i=column+15+strlen(buffer); i<79;i++)
	    mvwaddstr( maindisp, 4, i, " ");
	  if(disptm->tm_year>99) {
	    vdif_should=(disptm->tm_year-100)%32;
	    vdif_should=vdif_should*2+disptm->tm_mon/6;
	  }
	} else if (ierr==-898 &&   source==MK5) {
                                          /* 123456789012345678901234567890123456789012345678901234 */
	  wstandout(maindisp);
	  mvwaddstr( maindisp, 4, column+15, "Mark 5B sync required, use 's'.");
	  wstandend(maindisp);
	  mvwaddstr( maindisp, 4, column+15+31, "                       ");
 
	} else {                           /* 123456789012345678901234567890123456789012345678901234 */
	  wstandout(maindisp);
	  mvwaddstr( maindisp, 4, column+15, "Error from device, see log for details.");
	  wstandend(maindisp);
	  mvwaddstr( maindisp, 4, column+15+39, "               ");
	}

	if(formtime >= 0) {
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
	  mvwaddstr( maindisp, 5, column+15, buffer );
	} else                             /* 123456789012345678901234567890123456789012345678901234 */
	  mvwaddstr( maindisp, 5, column+15, "                                                      ");

	if(formtime >= 0) {
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
	  mvwaddstr( maindisp, 6, column+15, buffer );
	} else                             /* 123456789012345678901234567890123456789012345678901234 */
	  mvwaddstr( maindisp, 6, column+15, "                                                      ");
	if(source == RDBE) {
	  sprintf(buffer,"Nominal VDIF Epoch for %s time is %d",
		  form,vdif_should);
	  mvwaddstr( maindisp, 8, column, buffer );
	  
	} else if(source==MK5) {
	  char *pps_status,*freq_status,*source_status;
	  if((rack == VLBA4 && rack_type == VLBA45) ||
	     (rack == VLBA4 && rack_type == VLBA4C ) || 
	     (rack == VLBA4 && rack_type == VLBA4CDAS ) || 
	     (rack == MK4   && rack_type == MK45  ) || 
	     source==DBBC
	    /* was:
       * rack==DBBC && (rack_type==DBBC_DDC_FILA10G ||rack_type==DBBC_PFB_FILA10G) */
	     ) {
	    if(strcmp(mk5b_1pps,"vsi")==0)
	      pps_status="- okay                         ";
	    else
	      pps_status="- incorrect value, fix with 's'";
	    if(m5b_crate!=0) {
	      int crate;
	      if(1 != sscanf(mk5b_clock_freq,"%d",&crate)) {
		freq_status="- error decoding clock rate    ";
	      } else if(crate!=m5b_crate)
		freq_status="- incorrect value, fix with 's'";
	      else
		freq_status="- okay                         ";
	      if(strcmp(mk5b_clock_source,"ext")==0)
		source_status="- okay                         ";
	      else
		source_status="- incorrect value, fix with 's'";
	    } else {
	        freq_status="- no value set in equip.ctl    ";
	      if(strcmp(mk5b_clock_source,"ext")==0)
		source_status="- okay                         ";
	      else
		source_status="- incorrect value, fix manually";
	    }
	  } else {
	    pps_status="                               ";
	    freq_status="                               ";
	    if(strcmp(mk5b_clock_source,"ext")==0)
	      source_status="- okay                         ";
	    else
	      source_status="- incorrect value, fix manually";
	    source_status="                               ";
	  }
	      
	  sprintf(buffer,"1PPS Source:      %10s     %s",
		  mk5b_1pps,pps_status);
	  mvwaddstr( maindisp, 8, column, buffer );
	  sprintf(buffer,"Clock Frequency:  %10s     %s",
		  mk5b_clock_freq,freq_status);
	  mvwaddstr( maindisp, 9, column, buffer );
	  sprintf(buffer,"Clock Source:     %10s     %s",
		  mk5b_clock_source,source_status);
	  mvwaddstr( maindisp,10, column, buffer );
	}
	wrefresh ( maindisp );

	while (ERR!=(inc=wgetch( maindisp ))) {
	  m5rec=source == MK5 &&
	    shm_addr->disk_record.record.record==1 &&
	    shm_addr->disk_record.record.state.known==1;
	  switch ( tolower(inc) ) {
	case INC_KEY :  /* Increment seconds */
	  if(m5rec)
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	  if(!m5rec ||asksure(maindisp,m5rec,0)) {
	    setfmtime(formtime++,1,vdif_epoch);
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  goto build;
	  break;
	case DEC_KEY :  /* Decrement seconds */
	  if(m5rec)
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	  if(!m5rec ||asksure(maindisp,m5rec,0)) {
	    setfmtime(formtime--,-1,vdif_epoch);
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  goto build;
	  break;
	case VDIF_INC_KEY :  /* Increment VDIF Epoch */
	  if(source=RDBE) {
	    if(vdif_epoch < vdif_should) {
	      vdif_epoch++;
	      setfmtime(formtime,0,vdif_epoch);
	    }
	  }
	  goto build;
	  break;
	case VDIF_DEC_KEY :  /* Decrement VDIF Epoch */
	  if(source=RDBE) {
	    if(0 < vdif_epoch) {
	      vdif_epoch--;
	      setfmtime(formtime,0,vdif_epoch);
	    }
	  }
	  goto build;
	  break;
	case VDIF_NOM_KEY :  /* Nominal VDIF Epoch */
	  if(source=RDBE) {
	    vdif_epoch=vdif_should;
	    setfmtime(formtime,0,vdif_epoch);
	  }
	  goto build;
	  break;
	case SET_KEY :  /* Get time from user */
	  if(m5rec)
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	  if(!m5rec ||asksure(maindisp,m5rec,0)) {
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	    formtime = asktime( maindisp,&flag, formtime);
	    if(flag) {
	      setfmtime(formtime,0,vdif_epoch);
	      if(source == S2 && s2type == 1)
		changeds2das=1;
	      else
		changedfm=1;
	    }
	  }
	  goto build;
	  break;
	case EQ_KEY :  /* set form time to fs time */
	  if(m5rec)
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	  if(!m5rec ||asksure(maindisp,m5rec,0)) {
	    setfmtime(formtime=fstime+(fshs+50)/100,0,vdif_epoch);
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  goto build;
	  break;
	case ESC_KEY :  /* ESC character */
	  running = FALSE;
	  break;
	case TOGGLE_KEY:
	  if(toggle) {
	    temp=source;
	    source=other;
	    other=temp;
	    if(source == S2 || other==S2)
	      s2type = 1-s2type;
	    else
	      clear_area=1;
	  }
	  goto build;
	  break;
	case TOGGLE2_KEY:
	  if(toggle2) {
	    iDBBC=3-iDBBC;
	  }
	  goto build;
	  break;
	case 'a':
	  if(source== RDBE && shm_addr->rdbe_units[0])
	    iRDBE=1;
	  goto build;
	case 'b':
	  if(source== RDBE && shm_addr->rdbe_units[1])
	    iRDBE=2;
	  goto build;
	case 'c':
	  if(source== RDBE && shm_addr->rdbe_units[2])
	    iRDBE=3;
	  goto build;
	case 'd':
	  if(source== RDBE && shm_addr->rdbe_units[3])
	    iRDBE=4;
	  goto build;
	case SYNCH_KEY:
	  for (i=hint_row;i<hint_row+irow;i++)
	    mvwaddstr( maindisp, i, 1, blank);
	  if(source != S2 && (rack& MK4 || rack &VLBA4 || source == MK5 ||
			      source==DBBC 
   /* was:
    * rack==DBBC && (rack_type==DBBC_DDC_FILA10G ||rack_type==DBBC_PFB_FILA10G) */
			       || source == RDBE) &&
	     asksure( maindisp,m5rec,1)) {
	    synch=1;
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  if (synch && source==DBBC
        /* was:
	       * (rack==DBBC && (rack_type==DBBC_DDC_FILA10G || rack_type==DBBC_PFB_FILA10G)) */
	      && NULL!=fila10g_cfg) {
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	    fila10g_cfg_use=ask_fila10g_cfg(maindisp,fila10g_cfg);
	  }
	  goto build;
	  break;
	default:
	  running = TRUE;
	}

	}
} while ( running );

endwin ();
 if(changedfm && rack !=RDBE) {
   logit("Formatter time reset.",0,NULL);
   if(shm_addr->time.model != 'c' && shm_addr->time.model!='n'
      && shm_addr->time.icomputer[01 & shm_addr->time.index]==0)
     if(formtime < 0) {
       logit("Last FMSET formatter communication returned an error.",0,NULL);
       logit("Please reset FS time manually.",0,NULL);
       fprintf(stderr,"\n**\nLast FMSET formatter communication returned an error.\n");
       fprintf(stderr,"Please reset FS time manually.\n**\n\n");
       rte_sleep(SLEEP_TIME);
       logit(NULL,-7,"fv");

     } else 
       skd_run_arg("setcl",' ',ipr,"setcl offset");
   else
     if(formtime >0 )
       skd_run_arg("setcl",' ',ipr,"setcl");
 }
 if(changeds2das) {
   logit("S2DAS time reset.",0,NULL);
   skd_run_arg("setcl",' ',ipr,"setcl s2das");
 }
exit(0);

}
