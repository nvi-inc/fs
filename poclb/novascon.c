/*
   NOVAS-C
   Constants file

   Naval Observatory Vector Astrometry Subroutines
   C Version 1.0
   June, 1996

   NOVAS has no licensing requirements.  If you use NOVAS in an
   application, an acknowledgement of the Astronomical Applications
   Department of the U.S. Naval Observatory would be appropriate. Your
   input helps us justify continued development of NOVAS. 

   The User's Guide is the official reference for NOVAS C3.1 and may be cited as:

       Bangert, J., Puatua, W., Kaplan, G., Bartlett, J., Harris, W., Fredericks, A., & Monet, A. 
       2011, User's Guide to NOVAS Version C3.1 (Washington, DC: USNO).
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

