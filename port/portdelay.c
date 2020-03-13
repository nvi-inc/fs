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
#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>

int portdelay(port,maxc,time)
int port,maxc,time;
{
  struct termio term;

  if (ioctl(port, TCGETA, &term) == -1) {
    return -3;
  }

  term.c_cc[VMIN] = maxc;
  term.c_cc[VTIME] = (time+9)/10;

  if(ioctl (port, TCSETA, &term)==-1)
    return -8;

  return 0;
}
