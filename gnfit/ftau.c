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
#include <math.h>

#define MAX_PAR 3

double ftau(iwhich, x, par, npar)
int *iwhich, *npar;
double *x, par[MAX_PAR];
{
  double res;
  int i;

/*    y=a+Polynominal in first coordinate */

  if(*iwhich==0) {
    res=par[0]+par[2]*(1.0-exp(-par[1]**x));
  } else if(*iwhich==1) {
    res=1.0;
  } else if(*iwhich==2) {
    res = par[2]*exp(-par[1]**x)**x;
  } else
    res=0.0;
  
  return res;
}

