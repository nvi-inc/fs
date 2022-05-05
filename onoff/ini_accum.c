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

void ini_accum(itpis,accum)
int itpis[MAX_ONOFF_DET];
struct sample *accum;
{
  int i;

  accum->count=0;
  accum->stm=0.0;

  for(i=0;i<MAX_ONOFF_DET;i++)
    if(itpis[i]!=0) {
      accum->avg[i]=0.0;
      accum->sig[i]=0.0;
    }
}
