/*
 * Copyright (c) 2020, 2022, 2025, 2026 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
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
int iCore3H;
int RDBE_set_ticks;

WINDOW	* maindisp;  /* main display WINDOW data structure pointer */

unsigned char inbuf[512];      /* class i-o buffer */
unsigned char outbuf[512];     /* class i-o buffer */
int ip[5];           /* parameters for fs communications */
int inclass;         /* input class number */
int outclass;        /* output class number */
int rtn1, rtn2, msgflg, save; /* unused cls_get args */
int synch=0;
int nanosec=-1;
static int ipr[5] = { 0, 0, 0, 0, 0};
int dbbc_sync=0;
int nCore3H;

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
 int epoch;
 int index,icomputer;
 int column,i,j;
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
int kfirst = 1;
int dbbc3_pps_delay[MAX_DBBC3_IF];
int dbbc3_time_comm_delay;
int iIndex, use_setcl;
int dbbc3_pps_delay_display = 1;
int viewed[MAX_DBBC3_IF]= {0};
int agree[MAX_DBBC3_IF]= {0};
int was_some=1;
int was_some_count=0;
int need_view=1;


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

 nCore3H=shm_addr->dbbc3_ddc_ifs;
 iCore3H=1;

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
	    "fmset requires a VLBA/VLBA4/Mark IV/LBA4/S2-DAS/S2-RT/Mark5B/FILA10G/RDBE/DBBC3 - fmset aborting\n");
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
    if(source== DBBC3)
        while (ERR!=wgetch( maindisp )) /* drain additional key presses */
            ;
 if(clear_area) 
   for (i=4;i<hint_row+irow;i++)
     mvwaddstr( maindisp, i, 1, blank);

 clear_area=0;
 column=10;
 hint_row=8;
mvwaddstr( maindisp, 2, 6, "fmset - VLBA/Mark IV/S2-DAS/S2-RT/Mark5B/FiLa10G/RDBE/DBBC3 time set" );
 if(source == DBBC3) {
   column=6;
   hint_row=13;
   if(dbbc3_pps_delay_display) {
     form="        ";
     mvwaddstr( maindisp, 4, column, "            " );
   } else if(1==iCore3H) {
     form="Core3H-1";
     mvwaddstr( maindisp, 4, column, "Core3H-1    " );
   } else if(2==iCore3H) {
     form="Core3H-2";
     mvwaddstr( maindisp, 4, column, "Core3H-2    " );
   } else if(3==iCore3H) {
     form="Core3H-3";
     mvwaddstr( maindisp, 4, column, "Core3H-3    " );
   } else if(4==iCore3H) {
     form="Core3H-4";
     mvwaddstr( maindisp, 4, column, "Core3H-4    " );
   } else if(5==iCore3H) {
     form="Core3H-5";
     mvwaddstr( maindisp, 4, column, "Core3H-5    " );
   } else if(6==iCore3H) {
     form="Core3H-6";
     mvwaddstr( maindisp, 4, column, "Core3H-6    " );
   } else if(7==iCore3H) {
     form="Core3H-7";
     mvwaddstr( maindisp, 4, column, "Core3H-7    " );
   } else if(8==iCore3H) {
     form="Core3H-8";
     mvwaddstr( maindisp, 4, column, "Core3H-8    " );
   }
 } else if(source == RDBE) {
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

if (source==DBBC3) {
    irow=0;
    if(!dbbc3_pps_delay_display) {
        sprintf(buffer, "Use '1'-'%d' for Core3H board 1-%d.",nCore3H,nCore3H);
        mvwaddstr( maindisp, hint_row+irow++, column,buffer);
        sprintf(buffer, "    'n'/'p' for next/previous Core3H board (wraps around).");
        mvwaddstr( maindisp, hint_row+irow++, column,buffer);
        sprintf(buffer, "    'z'     toggle display between pps_delay and Core3H board time");
        mvwaddstr( maindisp, hint_row+irow++, column,buffer);
        irow++;
        sprintf(buffer, "Use '+'/'-' to increment/decrement %s time by one second.",form);
        mvwaddstr( maindisp, hint_row+irow++, column, buffer);
        sprintf(buffer, "    '='     to be prompted for a new %s time or use GPS.",form);
        mvwaddstr( maindisp, hint_row+irow++, column, buffer);
        sprintf(buffer, "    '.'     to set %s time to Field System time.",form);
        mvwaddstr( maindisp, hint_row+irow++, column, buffer);
        sprintf(buffer, "    's'     to SYNC DBBC3 (only needed if pps_delays are large)");
        mvwaddstr( maindisp, hint_row+irow++, column, buffer);
    } else {
        sprintf(buffer, "Use 'z'     toggle display between pps_delay and Core3H board time");
        mvwaddstr( maindisp, hint_row+irow++, column,buffer);
        irow+=1;
        sprintf(buffer, "Use 's'     to SYNC DBBC3 (only needed if pps_delays are large)");
        mvwaddstr( maindisp, hint_row+irow++, column, buffer);
    }
} else {
 sprintf(buffer, "Use '+'     to increment %s time by one second.",form);
   mvwaddstr( maindisp, hint_row, column,buffer);
 sprintf(buffer,"    '-'     to decrement %s time by one second." ,form);
 mvwaddstr( maindisp, hint_row+1, column, buffer);
 if(source==DBBC)
   sprintf(buffer, "    '='     to be prompted for a new %s time or use GPS.",form);
 else
   sprintf(buffer, "    '='     to be prompted for a new %s time.",form);
 mvwaddstr( maindisp, hint_row+2, column, buffer);
 sprintf(buffer, "    '.'     to set %s time to Field System time.",form);
 mvwaddstr( maindisp, hint_row+3, column, buffer);
 irow=4;
 }
 if(source==RDBE) {
   if(vdif_epoch < vdif_should && !kfirst) {
     sprintf(buffer,"    '>'     to increment %s VDIF epoch." ,form);
   } else
     sprintf(buffer,"                                             ");
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
   sprintf(buffer, "    's'     to SYNC %s (VERY rarely needed)",form);
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

 if(source==DBBC3)
    irow++;
 mvwaddstr( maindisp, hint_row+irow++, column,
	    "Use <esc>   to quit: DON'T LEAVE FMSET RUNNING FOR LONG.");

 if(source==RDBE && vdif_epoch == vdif_should)
   mvwaddstr( maindisp, hint_row+irow, 1, blank);

leaveok ( maindisp, FALSE); /* leave cursor in place */


do 	{

	char fmt[80];

        if(source==DBBC3 && !dbbc3_pps_delay_display && need_view) {
            int some=0;
            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++)
                some=some|| !viewed[i];

            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++)
                some=some|| viewed[i] && !agree[i];

            if(!some) {
                if(was_some && was_some_count<=0)
                    was_some_count=4;
                if (was_some_count>0) {
                    was_some_count--;
                    if(was_some_count==0) {
                        dbbc3_pps_delay_display=1;
                        need_view=0;
                        was_some=0;
                        clear_area=1;
                        goto build;
                    }
                }
            }
            was_some=some;
        }

	memset(mk5b_sync,' ',sizeof(mk5b_sync)-1);
	mk5b_sync[sizeof(mk5b_sync)-1]=0;
	getfmtime(&unixtime,&unixhs,&fstime, &fshs,
		  &formtime,&formhs,mk5b_sync,sizeof(mk5b_sync),
		  mk5b_1pps,sizeof(mk5b_1pps),
		  mk5b_clock_freq,sizeof(mk5b_clock_freq),
		  mk5b_clock_source,sizeof(mk5b_clock_source),
		  &vdif_epoch,dbbc3_pps_delay_display,dbbc3_pps_delay,
		  &dbbc3_time_comm_delay,&ierr); /* get times */

	vdif_should=-1;
	if(formtime>=0) {
	  disptime=formtime;
	  disphs=formhs+5;
	  if (disphs > 99) {
	    disphs-=100;
	    disptime++;
	  }
          if(source!= RDBE && source != DBBC3)
	    sprintf(fmt,"%%H:%%M:%%S.%01d UT  %%d %%b (Day %%j) %%Y %s   ",
		    disphs/10, mk5b_sync);
	  else
	    sprintf(fmt,"%%H:%%M:%%S.%01d UT  %%d %%b (Day %%j) %%Y VDIF Epoch %d ",
		    disphs/10, vdif_epoch);
	  disptm = gmtime(&disptime);
	  strftime ( buffer, sizeof(buffer), fmt, disptm );
	  if(source!=DBBC3)
              mvwaddstr( maindisp, 4, column+15, buffer );
	  else {
              int differ=abs(fstime-formtime) > 1 || abs((fstime-formtime)*100 +fshs-formhs)>50;
              viewed[iCore3H-1]=1;
              agree[iCore3H-1]=!differ;
              wmove( maindisp, 4, column+15);
              for(j=0;j<strlen(buffer);j++)
                  if(differ && j<36)
                      waddch(maindisp,buffer[j]|A_REVERSE);
                  else
                      waddch(maindisp,buffer[j]);
	  }
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
 
	} else if (source == DBBC3 && dbbc3_pps_delay_display) {
          mvwaddstr( maindisp, 4, 1, blank);
                                           /* 123456789012345678901234567890123456789012345678901234 */
	  wstandout(maindisp);
	  mvwaddstr( maindisp, 4, column+17, "pps_delay display selected, values are below");
	  wstandend(maindisp);
	} else {                           /* 123456789012345678901234567890123456789012345678901234 */
          mvwaddstr( maindisp, 4, 1, blank);
	  wstandout(maindisp);
	  mvwaddstr( maindisp, 4, column+15, "Error reading device, see log for details.");
	  wstandend(maindisp);
	  rte_sleep(200);
	}

	if(formtime < 0) {
          int it[6];
          rte_time(it,it+5);
          rte2secs(it,&fstime);
          fshs=it[0];
        }

        disptime=fstime;
        disphs=fshs+5;

        if (disphs > 99) {
            disphs-=100;
            disptime++;
        }

        index=01 & shm_addr->time.index;
        epoch=shm_addr->time.epoch[index];
        icomputer=shm_addr->time.icomputer[index];

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

        if(formtime < 0) {
            struct timeval tv;
            if(0!= gettimeofday(&tv, NULL)) {
                endwin ();
                perror("fmset, using gettimeofday(), fatal\n");
                rte_sleep(SLEEP_TIME);
                exit(-1);
            }
            unixtime=tv.tv_sec;
            unixhs=tv.tv_usec/10000;
        }
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

        if(source == RDBE) {
            sprintf(buffer,"Nominal VDIF Epoch for %s time is %d ",
                    form,vdif_should);
            mvwaddstr( maindisp, 8, column, buffer );

            if(kfirst) {
                kfirst=0;
                goto build;
            }
        } else if(source==DBBC3) {
            int some;
            if(!dbbc3_pps_delay_display) {
                sprintf(buffer,"Nominal VDIF Epoch for %s time is %d ",
                        form,vdif_should);
                mvwaddstr( maindisp, 8, column, buffer );
                mvwaddstr( maindisp, 9, 1, blank);
                mvwaddstr( maindisp, 9, column, "pps_delay: ");
                wstandout(maindisp);
                wprintw(maindisp,"time display selected, see %s time above",form);
                wstandend(maindisp);
                mvwaddstr( maindisp, 10, 1, blank);
            } else {
                mvwaddstr( maindisp, 9, 1, blank);
                if(dbbc3_pps_delay[0]<0) {
                    mvwaddstr( maindisp, 9, 1, blank);
                    mvwaddstr( maindisp, 9, column, "pps_delay: ");
                    wstandout(maindisp);
                    mvwaddstr( maindisp, 9, column+15, "Error reading device, see log for details.");
                    wstandend(maindisp);
                    mvwaddstr( maindisp, 10, 1, blank);
                    rte_sleep(100);
                } else {
                    int imax=4;
                    if(shm_addr->dbbc3_ddc_ifs<imax)
                        imax=shm_addr->dbbc3_ddc_ifs;
                    if(imax==1)
                        sprintf(buffer,"pps_delay: board    1:",imax);
                    else
                        sprintf(buffer,"pps_delay: boards 1-%d:",imax);
                    mvwaddstr( maindisp, 9, column, buffer );
                    for(i=0;i<imax;i++) {
                        sprintf(buffer," %10d",dbbc3_pps_delay[i]);
                        if(i!=imax-1)
                            strcat(buffer,",");
                        for(j=0;j<strlen(buffer);j++)
                            if(dbbc3_pps_delay[i]>100 && NULL!=strchr("01234567890-",buffer[j]))
                                waddch(maindisp,buffer[j]|A_REVERSE);
                            else
                                waddch(maindisp,buffer[j]);
                    }
                    if(4<shm_addr->dbbc3_ddc_ifs) {
                        imax=8;
                        if(shm_addr->dbbc3_ddc_ifs<imax)
                            imax=shm_addr->dbbc3_ddc_ifs;
                        if(imax==5)
                            sprintf(buffer,"           board    5:",imax);
                        else
                            sprintf(buffer,"           boards 5-%d:",imax);
                        mvwaddstr( maindisp,10, column, buffer );
                        for(i=4;i<imax;i++) {
                            sprintf(buffer," %10d",dbbc3_pps_delay[i]);
                            if(i!=imax-1)
                                strcat(buffer,",");
                            for(j=0;j<strlen(buffer);j++)
                                if(dbbc3_pps_delay[i]>100 && NULL!=strchr("01234567890-",buffer[j]))
                                    waddch(maindisp,buffer[j]|A_REVERSE);
                                else
                                    waddch(maindisp,buffer[j]);
                        }
                    } else
                        mvwaddstr( maindisp, 10, 1, blank);
                }
            }

            some=0;
            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++)
                some=some|| !viewed[i];
            mvwaddstr( maindisp,11, column, "Boards NOT viewed:");
            if(some) {
                for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                    wprintw(maindisp," ");
                    if(viewed[i])
                        wprintw(maindisp," ");
                    else {
                        wstandout(maindisp);
                        wprintw(maindisp,"%d",i+1);
                        wstandend(maindisp);
                    }
                }
            } else
                wprintw(maindisp,"            none");

            some=0;
            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++)
                some=some|| viewed[i] && !agree[i];
            wprintw( maindisp, "; viewed, time BAD:");
            if(some) {
                for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                    wprintw(maindisp," ");
                    if(!viewed[i] || agree[i])
                        wprintw(maindisp," ");
                    else {
                        wstandout(maindisp);
                        wprintw(maindisp,"%d",i+1);
                        wstandend(maindisp);
                    }
                }
            } else
                wprintw(maindisp," none            ");
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
            if(source== DBBC3)
                while (ERR!=wgetch( maindisp )) /* drain additional key presses */
                    ;    /* this one is unlikely to be needed, but is safe */
	  m5rec=source == MK5 &&
	    shm_addr->disk_record.record.record==1 &&
	    shm_addr->disk_record.record.state.known==1;
          if(source==DBBC3 && dbbc3_pps_delay_display &&
              NULL!=strchr("+-=.np12345678",inc))
                continue;
	  switch ( tolower(inc) ) {
	case INC_KEY :  /* Increment seconds */
          if(formtime<0)
            goto build;
	  if(source==DBBC3)
            formtime+=(dbbc3_time_comm_delay+50)/100;
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
          if(formtime<0)
            goto build;
	  if(source==DBBC3)
            formtime+=(dbbc3_time_comm_delay+50)/100;
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
	  if(source==RDBE) {
	    if(vdif_epoch < vdif_should) {
	      vdif_epoch++;
	      setfmtime(formtime,0,vdif_epoch);
	      changedfm=1;
	    }
	  }
	  goto build;
	  break;
	case VDIF_DEC_KEY :  /* Decrement VDIF Epoch */
          if(source==RDBE) {
            if(0 < vdif_epoch) {
	      vdif_epoch--;
	      setfmtime(formtime,0,vdif_epoch);
	      changedfm=1;
	    }
	  }
	  goto build;
	  break;
	case VDIF_NOM_KEY :  /* Nominal VDIF Epoch */
	  if(source==RDBE) {
	    vdif_epoch=vdif_should;
	    setfmtime(formtime,0,vdif_epoch);
	    changedfm=1;
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
            clear_area=1;
	  }
	  goto build;
	  break;
	case EQ_KEY :  /* set form time to fs time */
	  if(m5rec)
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
	  if(!m5rec ||asksure(maindisp,m5rec,0)) {
	    if(source==DBBC3)
              formtime=fstime+(fshs+dbbc3_time_comm_delay+50)/100;
            else
	       formtime=fstime+(fshs+50)/100;
	    setfmtime(formtime,0,vdif_epoch);
	    if(source == S2 && s2type == 1)
	      changeds2das=1;
	    else
	      changedfm=1;
	  }
	  goto build;
	  break;
	case ESC_KEY :  /* ESC character */
	    for (i=hint_row;i<hint_row+irow;i++)
	      mvwaddstr( maindisp, i, 1, blank);
          if(source!=DBBC3 ||
                  dbbc3_askexit(maindisp,viewed,agree,dbbc3_pps_delay,dbbc3_pps_delay_display,nCore3H))
              running = FALSE;
          else
              goto build;
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
            kfirst=1;
	  goto build;
	case 'b':
	  if(source== RDBE && shm_addr->rdbe_units[1])
	    iRDBE=2;
            kfirst=1;
	  goto build;
	case 'c':
	  if(source== RDBE && shm_addr->rdbe_units[2])
	    iRDBE=3;
            kfirst=1;
	  goto build;
	case 'd':
	  if(source== RDBE && shm_addr->rdbe_units[3])
	    iRDBE=4;
            kfirst=1;
	  goto build;
	case 'n':
	case 'N':
	  if(source== DBBC3)
	    iCore3H=1+ iCore3H%nCore3H;
          kfirst=1;
	  goto build;
	case 'p':
	case 'P':
	  if(source== DBBC3)
              iCore3H=1+ (iCore3H-2+nCore3H)%nCore3H;
          kfirst=1;
	  goto build;
	case 'z':
	case 'Z':
	  if(source== DBBC3)
              if(dbbc3_pps_delay_display)
                dbbc3_pps_delay_display=0;
              else
                dbbc3_pps_delay_display=1;
          kfirst=1;
	  clear_area=1;
	  goto build;
	case '1':
	  if(source== DBBC3 && 1 <= nCore3H)
              iCore3H=1;
          kfirst=1;
	  goto build;
	case '2':
	  if(source== DBBC3 && 2 <= nCore3H)
              iCore3H=2;
          kfirst=1;
	  goto build;
	case '3':
	  if(source== DBBC3 && 3 <= nCore3H)
              iCore3H=3;
          kfirst=1;
	  goto build;
	case '4':
	  if(source== DBBC3 && 4 <= nCore3H)
              iCore3H=4;
          kfirst=1;
	  goto build;
	case '5':
	  if(source== DBBC3 && 5 <= nCore3H)
              iCore3H=5;
          kfirst=1;
	  goto build;
	case '6':
	  if(source== DBBC3 && 6 <= nCore3H)
              iCore3H=6;
          kfirst=1;
	  goto build;
	case '7':
	  if(source== DBBC3 && 7 <= nCore3H)
              iCore3H=7;
          kfirst=1;
	  goto build;
	case '8':
	  if(source== DBBC3 && 8 <= nCore3H)
              iCore3H=8;
          kfirst=1;
	  goto build;
	case SYNCH_KEY:
	case SYNCH2_KEY:
	  for (i=hint_row;i<hint_row+irow;i++)
	    mvwaddstr( maindisp, i, 1, blank);
	  if(source != S2 && (rack& MK4 || rack &VLBA4 || source == MK5 ||
			      source==DBBC || source==DBBC3
   /* was:
    * rack==DBBC && (rack_type==DBBC_DDC_FILA10G ||rack_type==DBBC_PFB_FILA10G) */
			       || source == RDBE) &&
	     asksure( maindisp,m5rec,1)) {
	    synch=1;
            if(source==DBBC3) {
                dbbc3_pps_delay_display=1;
                for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                    viewed[i]=0;
                    agree[i]=0;
                }
                need_view=1;
            }
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

if(rack == RDBE && changedfm) {
   int ticks;
   rte_ticks(&ticks);
   if (ticks < RDBE_set_ticks+110)
       rte_sleep(110-(ticks-RDBE_set_ticks));
   for (i=0;i<MAX_RDBE;i++) {
      iRDBE=i+1;
      RDBE_data_send(1);
      }
}
endwin ();
iIndex = 01 & shm_addr->time.index;

use_setcl=shm_addr->time.model != 'n' && shm_addr->time.model != 'c' &&
shm_addr->time.icomputer[iIndex]==0;

if(changedfm && rack !=RDBE) {
    logit("Formatter time reset.",0,NULL);
    if(use_setcl) {
        if(formtime < 0) {
            logit("Last FMSET formatter communication returned an error.",0,NULL);
            logit("Please reset FS time manually.",0,NULL);
            fprintf(stderr,"\n**\nLast FMSET formatter communication returned an error.\n");
            fprintf(stderr,"Please reset FS time manually.\n**\n\n");
            rte_sleep(SLEEP_TIME);
            logit(NULL,-7,"fv");
        } else {
            logit("Resetting FS time with setcl.",0,NULL);
            if(source==DBBC3)
                rte_sleep(501);
            skd_run_arg("setcl",' ',ipr,"setcl offset");
        }
    }
}
if(changeds2das) {
    logit("S2DAS time reset.",0,NULL);
    if(use_setcl) {
        logit("Resetting FS time with setcl.",0,NULL);
        skd_run_arg("setcl",' ',ipr,"setcl s2das");
    }
}
exit(0);

}
