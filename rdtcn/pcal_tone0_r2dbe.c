/*
 * Copyright (c) 2025 NVI, Inc.
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

int pcal_tone0_r2dbe(int zero_channel, double pcal_offset, double pcal_spacing)
{
  double tone0_base=16e6+pcal_offset;
  int spacing=rint(pcal_spacing*1e-6);
  double new_floor=zero_channel*32e6+16e6;
  int i;

  if(spacing <=0 || pcal_offset <=0.0)
    return -1;

  for (i=0;i<2048/spacing;i++)
    if(new_floor < tone0_base+i*spacing*1e6)
      break;

  if(i>=2048/spacing)
    return -1;
  else
    return i*spacing;
}
