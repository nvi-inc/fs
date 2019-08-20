/* mout6 - RDBE monitor
 *
 */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>
#include <time.h>

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
  int seconds,dot2pps;
  struct tm *tm;
  int inv_vdif[4],vdif_should,inv_pps;

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
  if(tm->tm_year>99) {
    vdif_should=(tm->tm_year-100)%32;
    vdif_should=vdif_should*2+tm->tm_mon/6;
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
    
    move(ROW_A+i,COL_DOT);
    printw("%.4s.%.3s.%.2s:%.2s:%.2s",
	   local[i].epoch,
	   local[i].epoch+4,
	   local[i].epoch+7,
	   local[i].epoch+9,
	   local[i].epoch+11);

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
