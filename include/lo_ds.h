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
/* header file for lo data structures */

struct lo_cmd {     /* command parameters */
  double lo[MAX_LO];      /* >=0 0 net freq in MHZ of total first LO,
                             < 0 this LO undefined */
  int sideband[MAX_LO];   /* net sideband 0=unknown, 1=USB, 2=LSB */
  int pol[MAX_LO];        /* polarization 0=unknown, 1=RCP, 2=LCP */
  double spacing[MAX_LO]; /* >= 0 space in MHz, < 0 see pcal[] */
  double offset[MAX_LO];  /* >= 0 offset of first tone in the IF */
  int pcal[MAX_LO];       /* 0=unknown, 1 = off, undefined unless spacing[] < 0 */ 
};
