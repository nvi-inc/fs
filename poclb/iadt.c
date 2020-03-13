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
/* iadt

   Add an increment to the standard rte time array
   Copied from FORTRAN.
*/

static int itm[5]={100,60,60,24,366};
/* itm holds the maximum for each unit of time */

void iadt(it,idt,ires)
int it[6];     /* standard rte time array   */
int idt;       /* the increment to be added */
int ires;      /* resolution of idt, i.e. which unit of time applies */

{
  int i,iix;  

/* number of days in the year plus one */

  itm[4] = 366;
  /* not Y2.1K compliant */
  if (it[5]%4 == 0)
    itm[4]=367;

  iix = idt;

  for (i=ires-1; i<=4; i++) {
    it[i]=it[i]+iix;           /* increment */
    if (it[i] >= itm[i]) {     /* this unit has overflowed */
      if (i != 4) {            /* get the remainder for this unit */
         iix=it[i]/itm[i];        /* get the carry to the next higher unit */
         it[i]=it[i]%itm[i];      /* set current units to the remainder */ 
      } else
         it[4]=1+it[4]%itm[4];
    } else
      return;
  }
  it[5]=it[5]+1;  /* If we got here, all units have overflowed, up to the
                   * number of days in a year. Assume we haven't overflowed
                   * more than one year! */ 
}
