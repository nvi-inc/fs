/*
 * Copyright (c) 2020 NVI, Inc.
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
/*                                                                */
/*  HISTORY:                                                      */
/*  WHO  WHEN    WHAT                                             */
/*  gag  920714  Added a check for Mark IV rack and drive to      */
/*               to go along with Mark III rack and drive.        */
/*  nrv  921027  Added check for special source names             */
/*                                                                */
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include "mparm.h"
#include "dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"


extern struct fscom *shm_addr;

mout5()

{
  struct monit5_ping *ping;
  char vsn[9];
  int hours,mins;

  ping=shm_addr->monit5.ping+(shm_addr->monit5.pong)%2;
  
  move(ROW1+1,COL1);
  if (ping->active==0)
    printw(">");
  else
    printw(" ");

  move(ROW1+1,COL1+4);
  printw("        ");
  move(ROW1+1,COL1+4);
  strncpy(vsn,ping->bank[0].vsn,8);
  vsn[8]=0;
  printw(vsn);

  move(ROW1+1,COL1+12);
  if(ping->bank[0].seconds>=0.0) {
    hours=(ping->bank[0].seconds+0.5)/3600.0;
    mins=((ping->bank[0].seconds+0.5)-hours*3600.0)/60.0;
    printw("%5dh%.2dm",hours,mins);
  } else
    printw("         ");

  move(ROW1+1,COL1+21);
  if(ping->bank[0].gb>=0.0) {
    printw("%10.3lf",ping->bank[0].gb);
  } else
    printw("          ");

  move(ROW1+1,COL1+31);
  if(ping->bank[0].percent>=0.0) {
    printw("%6.1lf",ping->bank[0].percent);
  } else
    printw("      ");

  move(ROW1+1,COL1+37);
  if(ping->bank[0].itime[0]>=0) {
    printw("%3d:%.2d:%.2d",
	   ping->bank[0].itime[3],
	   ping->bank[0].itime[2],
	   ping->bank[0].itime[1]
	   );
  } else
    printw("         ");

  move(ROW1+2,COL1);
  if (ping->active==1)
    printw(">");
  else
    printw(" ");
    
  move(ROW1+2,COL1+4);
  printw("        ");
  move(ROW1+2,COL1+4);
  strncpy(vsn,ping->bank[1].vsn,8);
  vsn[8]=0;
  printw(vsn);

  move(ROW1+2,COL1+12);
  if(ping->bank[1].seconds>=0) {
    hours=(ping->bank[1].seconds+0.5)/3600.0;
    mins=((ping->bank[1].seconds+0.5)-hours*3600.0)/60.0;
    printw("%5dh%.2dm",hours,mins);
  } else
    printw("         ");

  move(ROW1+2,COL1+21);
  if(ping->bank[1].gb>=0.0) {
    printw("%10.3lf",ping->bank[1].gb);
  } else
    printw("          ");

  move(ROW1+2,COL1+31);
  if(ping->bank[1].percent>=0.0) {
    printw("%6.1lf",ping->bank[1].percent);
  } else
    printw("      ");

  move(ROW1+2,COL1+37);
  if(ping->bank[1].itime[0]>=0) {
    printw("%3d:%.2d:%.2d",
	   ping->bank[1].itime[3],
	   ping->bank[1].itime[2],
	   ping->bank[1].itime[1]
	   );
  } else
    printw("         ");

}  /* end mout2 */

