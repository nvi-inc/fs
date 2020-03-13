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
/* limit

   Limit angles to the useful range.
   Copied from FORTRAN.
*/

#include <math.h>
#include "../include/dpi.h"

void limit(a1,a2)
double *a1,*a2;
/* a1 is ra  or az, limited to 0 to 2pi
   a2 is dec or el, limited to -pi to +pi
*/

{
  *a1=fmod(*a1+DTWOPI,DTWOPI);
  if (fabs(*a2) > DPI/2.0) {
    *a2 = (*a2 > 0) ? DPI-*a2 : -DPI-*a2;
    *a1 = fmod(*a1+DPI,DTWOPI);
  }
}
