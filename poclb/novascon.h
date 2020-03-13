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
   Header file for novascon.c

   Naval Observatory Vector Astrometry Subroutines
   C Version 1.0
   June, 1996

   U. S. Naval Observatory
   Astronomical Applications Dept.
   3450 Massachusetts Ave., NW
   Washington, DC  20392-5420
*/

#ifndef _CONSTS_
   #define _CONSTS_

   extern const short int FN1;
   extern const short int FN0;

/*
   TDB Julian date of epoch J2000.0.
*/

   extern const double T0;

/*
   Astronomical Unit in kilometers.
*/

   extern const double KMAU;

/*
   Astronomical Unit in meters.
*/

   extern const double MAU;

/*
   Speed of light in AU/Day.
*/

   extern const double C;

/*
   Heliocentric gravitational constant.
*/

   extern const double GS;

/*
   Radius of Earth in kilometers.
*/

   extern const double EARTHRAD;

/*
   Value of pi in radians.

   extern const double PI;
*/
   extern const double TWOPI;

/*
   Angle conversion constants.
*/

   extern const double SECS2RADS;
   extern const double DEG2RAD;
   extern const double RAD2DEG;

#endif
