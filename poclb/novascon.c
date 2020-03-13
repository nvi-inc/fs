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
/*
   NOVAS-C
   Constants file

   Naval Observatory Vector Astrometry Subroutines
   C Version 1.0
   June, 1996

   U. S. Naval Observatory
   Astronomical Applications Dept.
   3450 Massachusetts Ave., NW
   Washington, DC  20392-5420
*/

#ifndef _CONSTS_
   #include "novascon.h"
#endif

const short int FN1 =       1;
const short int FN0 =       0;

/*
   TDB Julian date of epoch J2000.0.
*/

const double T0 =       2451545.0;

/*
   Astronomical Unit in kilometers.
*/

const double KMAU =     1.49597870e+8;

/*
   Astronomical Unit in meters.
*/

const double MAU =      1.49597870e+11;

/*
   Speed of light in AU/Day.
*/

const double C =        173.1446333;

/*
   Heliocentric gravitational constant.
*/

const double GS =       1.32712438e+20;

/*
   Radius of Earth in kilometers.
*/

const double EARTHRAD = 6378.140;

/*
   Value of pi in radians.
*/

const double PI =       3.14159265358979323846;
const double TWOPI =    6.28318530717958647692;

/*
   Angle conversion constants.
*/

const double SECS2RADS= 206264.806247096355;
const double DEG2RAD =  0.017453292519943296;
const double RAD2DEG =  57.295779513082321;

