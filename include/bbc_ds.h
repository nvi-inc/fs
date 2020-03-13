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
/* vlba bbc data structures */

struct bbc_cmd {
     int freq;        /* bits sent to bbc to command frequency */
     int source;       /* if source, 0=A, 1=B, 2=C, 3=D */
     int bw[2];        /* bandwidth selection */
     int bwcomp[2];    /* bandwidth gain compensation USB & LSB */
     struct {
       int mode;       /* 0=fixed, 1=AGC */
       int value[2];   /* */
       int old;        /* old setting */
     } gain;
     int avper;   /* averaging period for TPI, 0,1,2,4,10,20,40,60 secs*/
    };

struct bbc_mon {
     int lock;         /* 0=un-locked, 1=locked */
     unsigned pwr[2];  /* 0-65535 counts */
     int serno;        /* 12 bit serial number */
     int timing;       /* 0=error, 1=okay */
    };
