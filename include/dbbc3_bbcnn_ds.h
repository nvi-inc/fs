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
/* dbbc3 bbcnn data structures */

struct dbbc3_bbcnn_cmd {
     unsigned int freq;  /* frequency (Hz) */
     int source;          /* if source, 0=A, 1=B, 2=C, 3=D */
     int bw;              /* bandwidth selection */
     int avper;           /* averaging period for TPI seconds*/
    };

struct dbbc3_bbcnn_mon {
     int agc;          /* 0=man, 1=agc */
     int gain[2];      /* gain values, index 0=upper, 1=lower */
     unsigned tpon[2]; /* tpi cal on, index 0=upper, 1=lower, 0-65535 counts */
     unsigned tpoff[2];/* tpi cal on, index 0=upper, 1=lower, 0-65535 counts */
    };
