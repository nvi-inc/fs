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
/* dbbc3_cont_cal data structures */

struct dbbc3_cont_cal_cmd {
  int mode;         /* 0=off, 1=on */
  int polarity;     /* 0 no polarity change, no on/off swap 
                       1    polarity change, no on/off swap 
                       2 no polarity change,    on/off swap 
                       3    polarity change,    on/off swap */
  int freq;         /* cont cal signal frequency, 8-300000 Hz */
  int option;       /* 0 = output pulsed, 1 - output always on */
  int samples;      /* number of samples for Tsys */
};
