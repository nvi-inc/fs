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
/* header file for user_device data structures */

struct user_device_cmd {     /* command parameters */
  double lo[6];     /* >=0 0 net freq in MHZ of total first LO,
                                  < 0 this device undefined */
  int sideband[6];  /* net sideband 0=unknown, 1=USB, 2=LSB */
  int pol[6];       /* polarization 0=unknown, 1=RCP, 2=LCP */
  double center[6]; /* detector center frequency */
  int zero[6];      /* non-zero, zeroing supported, 0 no zeroing */
};
