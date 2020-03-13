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
/* header file for vlba dqa data structures */

struct dqa_cmd {         /* command parameters */
     int dur;            /* analysis duration in seconds */
     };

struct dqa_mon {         /* monitor only parameters */
     struct dqa_chan {   /* for each channel */
       int bbc;
       int track;
       float amp;        /* phase-cal amplitude in voltage percent */
       float phase;      /* phase-cal phase in radians */
                             /* error counts: */
       unsigned int parity;     /* parity errors */
       unsigned int crcc_a;     /* crcc-'a' errors */
       unsigned int crcc_b;     /* crcc-'b' errors */
       unsigned int resync;     /* resync errors */
       unsigned int nosync;     /* nosync errors */
       unsigned int num_bits;   /* number of bits actually sampled */
     } a;                /* one struct for channel a */
     struct dqa_chan b;  /* one struct for channel b */
     };
