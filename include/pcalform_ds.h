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
/* header file for pcalform data structures */

struct pcalform_cmd {
    int count[2][16];       /* number of tones for [u...l][1...16] */
    int which[2][16][17];   /* non-zero if this value uses "tones"
                               zero if this value uses freqs */
    int tones[2][16][17];   /* list of tones */
    int strlen[2][16][17];  /* length of input tone/freq input arg to aid
                               display */
    double freqs[2][16][17];/* list of frequencies */
};


