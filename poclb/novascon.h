/*
   NOVAS-C
   Header file for novascon.c

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
