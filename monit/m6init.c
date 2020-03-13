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
/* m6init -- RBDE monitor initialization of static characters
 *
 */

#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "mon6.h"

m6init()
{
  mvaddstr(ROW_TITLE0,COL_RDBE-1,   "RDBE");
  mvaddstr(ROW_TITLE0,COL_DOT,      "     DOT");
  mvaddstr(ROW_TITLE0,COL_EPOCH-1,    "EPOCH");
  mvaddstr(ROW_TITLE0,COL_DOT2GPS+4,  "DOT2GPS");
  mvaddstr(ROW_TITLE0,COL_DOT2PPS,    "DOT2PPS");
  mvaddstr(ROW_TITLE0,COL_RAW,      "IF  RMS");
  mvaddstr(ROW_TITLE0,COL_TSYS,     "IF0  TSys IF1  TSys");
  mvaddstr(ROW_TITLE0,COL_PCAL,     " Tone    Amp  Phase");

} 
