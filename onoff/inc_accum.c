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
#include "../include/params.h"

#include "sample_ds.h"

void inc_accum(itpis,accum,sample)
int itpis[MAX_ONOFF_DET];
struct sample *accum, *sample;
{
  int j;
  double dri,dim1;

  dri=1.0/(double) ++(accum->count);
  dim1=accum->count-1;

  /* recursive mean for time value */
  accum->stm=(accum->stm*dim1+sample->stm)*dri;

  for(j=0;j<MAX_ONOFF_DET;j++)
    if(itpis[j]!=0) {
  /* recursive mean for samples */
      accum->avg[j]=(accum->avg[j]*dim1+sample->avg[j])*dri;
  /* recursive mean for squares of samples */
      accum->sig[j]=(accum->sig[j]*dim1+sample->avg[j]*sample->avg[j])*dri;
    }
}
