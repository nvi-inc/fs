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
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void preflt(outf,flnum,width,deci)

char *outf;
float flnum;
int width,deci;

{
  void flt2str();

  outf[0]=0;
  flt2str(outf,flnum,width,deci);

}

void preint(outi,inum,width,zorb)

char *outi;
int inum;
int width,zorb;

{
  void int2str();

  *outi=0;
  int2str(outi,inum,width,zorb);

}
