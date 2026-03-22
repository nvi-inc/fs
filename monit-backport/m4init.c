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
#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include "mparm.h"

void m4init(int n_das, int mode)
{
  standout();
  mvprintw(ROW1,   COL1,"                                  DAS MONITOR                                  ");
  standend();
  mvprintw(ROW1+1, COL1,"                                                                               ");
  mvprintw(ROW1+2, COL1,"              IF PROCESSOR %d:          |               IF PROCESSOR %d:         ",2*n_das+1,2*n_das+2);
  mvprintw(ROW1+3, COL1,"IFP%d:                                  | IFP%d:                                 ",2*n_das+1,2*n_das+2);
  mvprintw(ROW1+4, COL1, "---------------------------------------+---------------------------------------");
	
  if (mode==0) {

	mvprintw(ROW1+5, COL1, "IF  :                                  | IF  :                                 ");
	mvprintw(ROW1+6, COL1, "LEVL: >--------------^--------------<  | LEVL: >--------------^--------------< ");
	mvprintw(ROW1+7, COL1, "OFFS: >--------------^--------------<  | OFFS: >--------------^--------------< ");
	mvprintw(ROW1+8, COL1, "                                       |                                       ");
	mvprintw(ROW1+9, COL1, "BS  :                                  | BS  :                                 ");
	mvprintw(ROW1+10,COL1, "U-TH: >--------------^--------------<  | U-TH: >--------------^--------------< ");
	mvprintw(ROW1+11,COL1, "L-TH: >--------------^--------------<  | L-TH: >--------------^--------------< ");
	mvprintw(ROW1+12,COL1, "                                       |                                       ");
	mvprintw(ROW1+13,COL1, "FT  :                                  | FT  :                                 ");
	mvprintw(ROW1+14,COL1, "U-TH: >--------------^--------------<  | U-TH: >--------------^--------------< ");
	mvprintw(ROW1+15,COL1, "L-TH: >--------------^--------------<  | L-TH: >--------------^--------------< ");
	mvprintw(ROW1+16,COL1, "                                       |                                       ");
	mvprintw(ROW1+17,COL1, "---------------------------------------+---------------------------------------");
	mvprintw(ROW1+18,COL1, "                                       |                                       ");
	mvprintw(ROW1+19,COL1, "CLKS:               BLANK:             | CLKS:               BLANK:            ");
	mvprintw(ROW1+20,COL1, "5 MHz:              1 PPS:             | 5 MHz:              1 PPS:            ");
	mvprintw(ROW1+21,COL1, "VOLTS:              TEMPS:             | VOLTS:              TEMPS:            ");
	mvprintw(ROW1+22,COL1, "                                       |                                       ");

  } else {

	mvprintw(ROW1+5 ,COL1, "LEVL:               OFFS:              | LEVL:               OFFS:             ");
	mvprintw(ROW1+6 ,COL1, "                                       |                                       ");
	mvprintw(ROW1+7 ,COL1, "U-TH:               L-TH:              | U-TH:               L-TH:             ");
	mvprintw(ROW1+8 ,COL1, "CNTR:               CNTR:              | CNTR:               CNTR:             ");
	mvprintw(ROW1+9 ,COL1, "                                       |                                       ");
	mvprintw(ROW1+10,COL1, "U-TH:               L-TH:              | U-TH:               L-TH:             ");
	mvprintw(ROW1+11,COL1, "CNTR:               CNTR:              | CNTR:               CNTR:             ");
	mvprintw(ROW1+12,COL1, "                                       |                                       ");
	mvprintw(ROW1+13,COL1 ,"1PLL_LD:            1PLL_VC:           | 1PLL_LD:            1PLL_VC:          ");
	mvprintw(ROW1+14,COL1, "---------------------------------------+---------------------------------------");
	mvprintw(ROW1+15,COL1 ,"CLK_MONITOR:        FILTER:            |                     FILTER:           ");
	mvprintw(ROW1+16,COL1, "5 MHz:              1 PPS:             | 5 MHz:              1 PPS:            ");
	mvprintw(ROW1+17,COL1, "---------------------------------------+---------------------------------------");
	mvprintw(ROW1+18,COL1 ,"TEMP MONITOR: ( Warning Thresh. in [] )|                                       ");
	mvprintw(ROW1+19,COL1, "SAMPLER:            FILTER:            | SAMPLER:            FILTER:           ");
	mvprintw(ROW1+20,COL1, "---------------------------------------+---------------------------------------");
	mvprintw(ROW1+21,COL1 ,"VOLTAGE MON:          IFP1 +5V:            +9V:               +15V:            ");
	mvprintw(ROW1+22,COL1 ,"  -5.2V:              IFP2 +5V:            -9V:               -15V:            ");

  }
  mvprintw(ROW1+23,COL1, "---------------------------------------+---------------------------------------");

}  /* end m2init */
