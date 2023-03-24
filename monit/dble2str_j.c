/*
 * Copyright (c) 2023 NVI, Inc.
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
#include <stdlib.h>
#include <string.h>

void dble2str_j(output,fvalue,width,deci)     /* floating print to string */
char *output;                              /* output string to append to */
double fvalue;                              /* value to convert */
int width;        /* maximum field width, >0 left justify, <0 right justify */
                  /* fewer than width characters may be used for left just. */
int deci;         /* digits after decimal point, >=0 blank fill for right   */
                  /* justify, <0 zero fill, 0 will print decimal point */
/* if output won't fit in specified width, that many characters are filled  */
/* with dollar signs, but first will try to display with fewer fractional   */
/* digits
/* this function is intended to be a replacement for FORTRAN jr2as routine */
{
   dble2str(output,fvalue,width,deci);
   if('$' != output[strlen(output)-1])
      return;
   output[strlen(output)-abs(width)]=0;
   dble2str(output,fvalue,abs(width)+abs(deci)+1,deci);
   output[strlen(output)-(abs(deci)+1)]=0;
   return;
}
