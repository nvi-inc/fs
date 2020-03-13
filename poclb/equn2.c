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
/* equn2

   Equation of equinoxes to about 0.1 ms of time
*/

#include <math.h>
#include <stdio.h>
#include "../include/dpi.h"

void equn2(it,eqeq)
int it[6];
double *eqeq;
{
  double julianhi, julianlo;
  double tdb,oblm,oblt,psi,eps;

  julianhi=julda(it[4],it[5]-1900)+ 2440000.0 - 1.0;
  julianlo = ((double)it[0]*.01 + (double)it[1] + (double)it[2]*60.0 
	      + (double)it[3]*3600.0)/86400.0+0.5;
/*
  printf(" julianhi %lf julianlo %lf\n",julianhi,julianlo);
*/
  tdb=julianhi+julianlo;

  earthtilt (tdb, &oblm,&oblt,eqeq,&psi,&eps);

  *eqeq*=DPI/(double) 43200.0;
}



