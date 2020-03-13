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
/* vlba formmatter data structures */

struct vform_cmd {
     int mode;         /* MK3 mode 0=prn,v,m,a,b,c,d1,...d28 */
     int rate;         /* (1<<rate)*0.25 MHz, 0<=rate<=7 */
     int format;       /* format spec */
     struct {
       unsigned low;          /* bits 0-15=tracks  0-15, 1=enable, 0=off */
       unsigned high;         /* bits 0-15=tracks 16-31 */
       unsigned system;       /* bits 0- 3=tracks 32-35 */
    } enable;
    unsigned aux[28][ 4];   /* aux data */
    int codes[32];      /* sampler pin codes for output tracks */
     int fan;           /* fan-in, fan-out mode */
     int barrel;        /* barrel-rolling mode */
    int tape_clock;
    struct {           /* QA set-up */
     int drive;        /* which drive, normally 1 */
     int chan;         /* capture channel, see 4 LSBs of formatter word 0x1A */
    } qa;
     int last;         /* =1 if vform was last, 0 if trackform */
   };

struct vform_mon {
     int version;      /* hex version number */
     int sys_st;       /* contents of FM address 20 */
     int mcb_st;       /* contents of FM address 21 */
     int hdw_st;       /* contents of FM address 22 */
     int sfw_st;       /* contents of FM address 23 */
     int int_st;       /* contents of FM address 24 */
    };
