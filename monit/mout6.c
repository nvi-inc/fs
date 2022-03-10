/*
 * Copyright (c) 2020, 2022 NVI, Inc.
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
/* mout6 - RDBE monitor
 *
 */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "mon6.h"

extern struct fscom *fs;

static char unit_letters[ ] = {" abcdefghijklm"}; /* mk6/rdbe unit letters */

mout6()
{
  int i;
  struct rdbe_tsys_cycle local[MAX_RDBE];
  char outflt[12];
  int tone, chan;
  int iping[4];
  int it[6];
  time_t seconds;
  int dot2pps;
  struct tm *tm;
  int inv_vdif[4],vdif_should,inv_pps;
  int inv_dot[4];
  char dot_should[14];

  for (i=0;i<MAX_RDBE;i++) {
    inv_vdif[i]=0;

    if(0==fs->rdbe_active[i])
      continue;

    move(ROW_A+i,0);
    printw(" %c",unit_letters[i+1]);
    clrtoeol();

    iping[i]=fs->rdbe_tsys_data[i].iping;
    if(iping[i] < 0 || iping[i] > 1)
      continue;

    memcpy(&local[i],
	   &fs->rdbe_tsys_data[i].data[iping[i]],
	   sizeof(struct rdbe_tsys_cycle));      
  }

  rte_time(it,it+5);
  rte2secs(it,&seconds);
  tm = gmtime(&seconds);

  vdif_should=-1;
  memset(dot_should,0,sizeof(dot_should));
  if(tm->tm_year>99) {
    vdif_should=(tm->tm_year-100)%32;
    vdif_should=vdif_should*2+tm->tm_mon/6;
    snprintf(dot_should,sizeof(dot_should),"%04d%03d%02d%02d%02d",
            tm->tm_year+1900,
            tm->tm_yday+1,
            tm->tm_hour,
            tm->tm_min,
            tm->tm_sec);
  }

  for(i=0;i<MAX_RDBE;i++) {
    inv_dot[i]=0;
    if(0!=fs->rdbe_active[i] && (iping[i]==0 || iping[i]==1) &&
      memcmp(local[i].epoch,dot_should,13))
        inv_dot[i]=1;
  }

  if(vdif_should>=0) {
    int valid[MAX_RDBE],same[MAX_RDBE];
    int active=0;
    int i,j, max, imax;
    for(i=0;i<MAX_RDBE;i++) { /* determine #active(valid), which valid, and
				 how many are same for each valid RDBE*/
      same[i]=0;
      valid[i]=0;
      if(0!=fs->rdbe_active[i] && (iping[i]==0 || iping[i]==1)) {
	valid[i]=1;
	active++;
	for(j=i+1;j<MAX_RDBE;j++)
	  if(0!=fs->rdbe_active[j] && (iping[j]==0 || iping[j]==1)) {
	    if(local[i].epoch_vdif==local[j].epoch_vdif)
	      same[i]++;
	  }
      }
    }

    max=0;
    imax==-1;
    for(i=0;i<MAX_RDBE;i++)  /* find the one with the most the same */
      if(same[i]>max) {
	max=same[i];
	imax=i;
      }

    if(max!=active-1) /* decide which ones to flag */
      if(max==0) { /* all different, flag all with non-nominal epoch */
	for(i=0;i<MAX_RDBE;i++)
	  if(valid[i] && local[i].epoch_vdif!=vdif_should)
	    inv_vdif[i]=1;
      } else /* flag those don't agree with majority */
	for(j=0;j<MAX_RDBE;j++)
	  if(valid[j] && local[imax].epoch_vdif!=local[j].epoch_vdif)
	    inv_vdif[j]=1;
  }

  for (i=0;i<MAX_RDBE;i++) {
    if(0==fs->rdbe_active[i])
      continue;

    if(iping[i]<0 || iping[i] >1)
      continue;
    
    if(inv_dot[i])
      standout();

    move(ROW_A+i,COL_DOT);
    printw("%.4s.%.3s.%.2s:%.2s:%.2s",
	   local[i].epoch,
	   local[i].epoch+4,
	   local[i].epoch+7,
	   local[i].epoch+9,
	   local[i].epoch+11);
    if(inv_dot[i])
      standend();

    if(local[i].epoch_vdif<100)
    if(inv_vdif[i])
      standout();
    if(local[i].epoch_vdif<100) {
      move(ROW_A+i,COL_EPOCH+1);
      printw("%2d",local[i].epoch_vdif);
    } else {
      move(ROW_A+i,COL_EPOCH);
      printw("%3d",local[i].epoch_vdif);
    }
    if(inv_vdif[i])
      standend();
    
    move(ROW_A+i,COL_DOT2GPS);
    printw("%11.3f",local[i].dot2gps*1e6);

    if(fs->monit6.dot2pps_ns > 0 &&
       (local[i].dot2pps < -1e-9*fs->monit6.dot2pps_ns ||
	local[i].dot2pps > +1e-9*fs->monit6.dot2pps_ns))
      inv_pps=1;
    else
      inv_pps=0;

    if(local[i].dot2pps>=0)
      dot2pps=local[i].dot2pps*1e6+0.5;
    else
      dot2pps=local[i].dot2pps*1e6-0.5;
    move(ROW_A+i,COL_DOT2PPS);
    if(inv_pps)
      standout();

    if(dot2pps<=-1000000)
      printw("<=-1sec");
    else if(dot2pps>=1000000)
      printw(">=+1sec");
    else
      printw("%7.3f",local[i].dot2pps*1e6);
    if(inv_pps)
      standend();

    move(ROW_A+i,COL_DOT2PPS+7);
    printw(" ");

    move(ROW_A+i,COL_RAW);
    printw("%2d ",local[i].raw_ifx);
    if(local[i].sigma < fs->rdbe_equip.rms_min ||
       local[i].sigma > fs->rdbe_equip.rms_max) 
      standout();
    printw("%4.1f",local[i].sigma);
    if(local[i].sigma < fs->rdbe_equip.rms_min ||
       local[i].sigma > fs->rdbe_equip.rms_max) 
      standend();
    
    chan=fs->monit6.tsys[0][i];
    if(local[i].tsys[chan][0]>=-1e12) {
      move(ROW_A+i,COL_TSYS);
      if(chan==MAX_RDBE_CH)
	printw("Avg",chan);
      else if(chan==MAX_RDBE_CH+1)
	printw("Sum",chan);
      else
	printw(" %02d",chan);
      move(ROW_A+i,COL_TSYS+4);
      outflt[0]=0;
      flt2str(outflt,local[i].tsys[chan][0],-5,1);
      printw("%s",outflt);
    }
    chan=fs->monit6.tsys[1][i];
    if(local[i].tsys[chan][1]>=-1e12) {
      move(ROW_A+i,COL_TSYS+10);
      if(chan==MAX_RDBE_CH)
	printw("Avg",chan);
      else if(chan==MAX_RDBE_CH+1)
	printw("Sum",chan);
      else
	printw(" %02d",chan);
      move(ROW_A+i,COL_TSYS+14);
      outflt[0]=0;
      flt2str(outflt,local[i].tsys[chan][1],-5,1);
      printw("%s",outflt);
    }

    if(local[i].pcaloff>0.1) {
      tone=fs->monit6.pcal[local[i].pcal_ifx][i];
      move(ROW_A+i,COL_PCAL);
      printw("%.1d%c%04d %5.1f %6.1f",
	     local[i].pcal_ifx,unit_letters[i+1],tone,
	     local[i].pcal_amp[tone],
	     local[i].pcal_phase[tone]);
    }
  }
}
