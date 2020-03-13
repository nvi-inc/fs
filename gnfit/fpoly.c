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
#define MAX_PAR 10

double fpoly(iwhich, x, par, npar)
int *iwhich, *npar;
double *x, par[MAX_PAR];
{
  double res;
  int i;

/*    Polynominal in first coordinate */

  if(*iwhich==0) {
    res=0.0;
    for (i=*npar-1;i>-1;i--)
      res=res**x+par[i];
  } else if(*iwhich>=1) {
    res=1.0;
    for (i=1;i<*iwhich;i++)
      res=res**x;
  } else
    res=0.0;
  
  return res;
}

