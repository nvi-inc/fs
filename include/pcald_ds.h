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
/* header file for pcald data structures */

struct pcald_cmd {
  int continuous;          /* 0 = controled by data_valid, 1 = continuous */
  int bits;                /* 0 = "best", 1,2 = 1,2 bit extraction */
  int integration;         /* integration period in centi-seconds
                              0 = nominal phase error less than 1 degree */
  int stop_request;
  int count[2][16];        /* number of tones for [u...l][1...16] */
  double freqs[2][16][17]; /* list of frequencies, < 0 for state counting */
};

