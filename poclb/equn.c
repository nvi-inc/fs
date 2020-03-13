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
/* equn

   Equation of equinoxes to about 0.1 s of time, extracted
   from J. Ball's MOVE routine. Copied from EQUN in POLB.
   NRV 920309
*/

#include <math.h>

void equn(nyrf,nday,eqofeq)
int nyrf;         /* year since 1900 */
int nday;         /* day of year     */
double *eqofeq;   /* equation of equinoxes */

{
  double a1,a,t,aomega,arg,dlong,doblq;

  a1=nday;
  a=nyrf;
  t = (a + a1/365.2421988)/100.0;

/* Nutation  */

  aomega=259.183275-1934.142*t;
  arg=aomega*0.0174532925;
  dlong= -8.3597e-5*sin(arg);

  *eqofeq=dlong*0.917450512;
}

