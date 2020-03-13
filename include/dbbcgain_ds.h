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
/* dbbcifX data structures */

struct dbbcgain_cmd {
     int bbc;          /* bbc, 0=all, or 1-16 */
     int state;        /* 0=man, 1=agc, -1=set gainU, gainL, -2=query */
     int gainU;        /* 1-255 */
     int gainL;        /* 1-255 */
     int target;       /* if state=1, 0-65535 target, -1 == NULL  */
    };
struct dbbcgain_mon {
     int state;        /* 0=man, 1=agc */
     int target;       /* if state=1, 0-65535 target, -1 == NULL  */
    };
