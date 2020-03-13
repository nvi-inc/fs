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

#include "../include/params.h"

#include "sample_ds.h"

void red_accum(itpis,accum)
int itpis[MAX_ONOFF_DET];
struct sample *accum;
{
  int j;
  double drdrm1;

/* average is already in final form */

/* calculate sigma as the average of squares minus square of average */

  if(accum->count>1) {
    drdrm1=((double) accum->count)/((double) (accum->count-1));
    for(j=0;j<MAX_ONOFF_DET;j++) {
      if(itpis[j]!=0) {
	double num;
	num=accum->sig[j]-accum->avg[j]*accum->avg[j];
	if(num <=0.0) 
	  accum->sig[j]=0.0;
	else
	  accum->sig[j]= sqrt(fabs(num)*drdrm1);
      }
    }
  } else {
/* only one point so assume sigma is from RMS of +/-0.5% */
    for(j=0;j<MAX_ONOFF_DET;j++) {
      if(itpis[j]!=0)
       accum->sig[j]=fabs(accum->avg[j])*0.0033;
    }
  }
}

