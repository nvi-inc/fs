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
/* Mark IV formmatter data structures */

struct form4_cmd {
  int mode;         /* MK3 mode 0=m,a,b1,b2,c1,c2,d1,...d28 */
  int rate;         /* (1<<rate)*0.125 MHz, 0<=rate<=8 */
  unsigned int enable[2]; /*track enables 1=enable, 0=off */
  unsigned aux[2];   /* aux data */
  int codes[64];     /* sampler pin codes for output tracks */
  int bits;          /* 1 or 2 for number of bits being used */
  int fan;           /* fan-in, fan-out mode */
  int barrel;        /* barrel-rolling mode, 0=off, 1=8, 2=16, 3=m */
  int modulate;     /* 0=no modulation, 1=modulation on */
  int last;         /* =1 if form was last, 0 if trackform */
  int synch;        /* synch on 0...16 or off=-1, pass=-2 fail=-3 */
  int roll[16][64]; /* table of arbitrary barrel-rolls */
  int start_map;
  int end_map;
  int a2d[16][64];  /* table of a2d assignment */
};

struct form4_mon {
  int status;
  int error;
  int rack_ids;     /* MAT rack_ids */
  int version;      /* version number */
};
