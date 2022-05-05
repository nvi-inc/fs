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
#include <termio.h>

int portbaud_(port, baud)   /* only to reset MAT BAUD */
int *port;
int *baud;
{
  struct termio term;

  if (ioctl(*port, TCSBRK, 0)==-1)   /* send a break to reset mats */
    return -1;

  if (ioctl(*port, TCGETA, &term) == -1)
    return -2;

  if (*baud>9600)
    return -3;

  term.c_cflag &= ~CBAUD;
  term.c_cflag &= ~CSTOPB;
  switch ((int) *baud){
    case 110:
      term.c_cflag |= B110;
      term.c_cflag |= CSTOPB;
      break;
    case 300:
      term.c_cflag |= B300;
      break;
    case 600:
      term.c_cflag |= B600;
      break;
    case 1200:
      term.c_cflag |= B1200;
      break;
    case 2400:
      term.c_cflag |= B2400;
      break;
    case 4800:
      term.c_cflag |= B4800;
      break;
    case 9600:
      term.c_cflag |= B9600;
      term.c_cflag |= CSTOPB;
      break; 
    default:
      return -3;
      break;
  }
  if(ioctl (*port, TCSETA, &term)==-1)
    return -4;

  return 0;
}
