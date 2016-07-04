/* mout6 - RDBE monitor
 *
 */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>

#include "mon6.h"
#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *fs;

static char unit_letters[ ] = {" abcdefghijklm"}; /* mk6/rdbe unit letters */

mout6()
{
  int i;
  struct rdbe_tsys_cycle local;
  char outflt[12];

  for (i=0;i<MAX_RDBE;i++) {
    int iping=fs->rdbe_tsys_data[i].iping;

    move(ROW_A+i,0);
    clrtoeol();
    if(0==fs->rdbe_active[i])
      continue;
    printw(" %c",unit_letters[i+1]);
    if(iping<0 || iping >1)
      continue;

    memcpy(&local,
	   &fs->rdbe_tsys_data[i].data[iping],
	   sizeof(struct rdbe_tsys_cycle));      
    
    move(ROW_A+i,COL_DOT);
    printw("%.4s.%.3s.%.2s:%.2s:%.2s",
	   local.epoch,
	   local.epoch+4,
	   local.epoch+7,
	   local.epoch+9,
	   local.epoch+11);

    move(ROW_A+i,COL_DOT2GPS);
    printw("%11.3f",local.dot2gps*1e6);
    
    move(ROW_A+i,COL_EPOCH);
    printw("%3d",local.epoch_vdif);
    
    move(ROW_A+i,COL_RAW);
    if(local.sigma < fs->rdbe_equip.rms_min ||
       local.sigma > fs->rdbe_equip.rms_max) 
      standout();
    printw("%2d %4.1f",local.raw_ifx,local.sigma);
    if(local.sigma < fs->rdbe_equip.rms_min ||
       local.sigma > fs->rdbe_equip.rms_max) 
      standend();
    
    if(local.tsys[MAX_RDBE_CH][0]>=-1e12) {
      move(ROW_A+i,COL_TSYS);
      outflt[0]=0;
      flt2str(outflt,local.tsys[MAX_RDBE_CH][0],-5,1);
      printw("%s",outflt);
    }
    if(local.tsys[MAX_RDBE_CH][1]>=-1e12) {
      move(ROW_A+i,COL_TSYS+7);
      outflt[0]=0;
      flt2str(outflt,local.tsys[MAX_RDBE_CH][1],-5,1);
      printw("%s",outflt);
    }

#define PCAL_TONE  30
    move(ROW_A+i,COL_PCAL);
    printw("%.1d%c%04d %5.1f %6.1f",
	   local.pcal_ifx,unit_letters[i+1],PCAL_TONE,
	   local.pcal_amp[PCAL_TONE],
	   local.pcal_phase[PCAL_TONE]);
  }
}
