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
/* header file for onoff data structures */

struct onoff_cmd {
  int rep;              /* repetitions, number */
  int intp;             /* integration period, seconds */
  float cutoff;         /* angle to switch to el instead of az offs, degrees */
  float step;           /* step size in FWHMs */
  int wait;             /* wait time for on to off transition */
  float ssize;           /* source size, radians */
  char proc[33];        /* procedure for first points */
  struct onoff_devices {
    char lwhat[4];      /* device ID */
    char pol;           /* polarization */
    int ifchain;        /* which IF */
    float flux;         /* source flux */
    float corr;         /* source structure correction */
    double center;      /* detector center frequency */
    float fwhm;         /* full width half maximum (degrees) */
    float tcal;        /* cal temperature */
    float dpfu;         /* degrees per flux unit (gain) */
    float gain;        /* gain curve, maximum=1.0 */
  } devices[MAX_ONOFF_DET];
  int itpis[MAX_ONOFF_DET];        /* control array for which devices */
  float fwhm;        /* FWHM for detector with the widest beam */
  int stop_request;     /* stop request issued? */
  int setup;            /* have we been set-up */
};

