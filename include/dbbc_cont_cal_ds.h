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
/* dbbc_cont_cal data structures */

struct dbbc_cont_cal_cmd {
  int mode;         /* 0=off, 1=on */
  int polarity;     /* not present before v105x_1
                       as of v105x_1:
                         0 no polarity change
                         1    polarity change
                       as of v106:
                         0 no polarity change, no on/off swap 
                         1    polarity change, no on/off swap 
                         2 no polarity change,    on/off swap 
                         3    polarity change,    on/off swap 
                       as of v107:
                         0 no 1 pps embedded, no on/off swap 
                         1    1 pps embedded, no on/off swap 
                         2 no 1 pps embedded,    on/off swap 
                         3    1 pps embedded,    on/off swap 
                    */
  int freq;         /* not present before v106
                       8-300000 Hz */
  int option;       /* not present before v106
                       0=pulsed, 1= output always on */

  int samples;      /* number of samples for Tsys */
};
