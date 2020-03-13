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
/* header file for vlba ifd (dist) data structures */

/* each instance of a structure refers to one distributor */
/* arrays index over the channels in a distributor */

struct dist_cmd {        /* command parameters */
     int atten[2];       /* attenutor settings, 0 or 20 */
     int input[2];       /* input selction, 0 or 1 */
     int avper;          /* averaging period */
     int old[2];         /* `old' attenuator settings (atten[]) */
     };

struct dist_mon {        /* monitor only parameters */
     int serial;         /* 12 bits of serial number */
     int timing;         /* timing status, 0 or 1 */
     unsigned totpwr[2]; /* total power counts */
     };
