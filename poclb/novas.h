/*
   NOVAS-C
   Header file for novas.c

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

#ifndef _NOVAS_
   #define _NOVAS_

   #ifndef __STDIO__
      #include "stdio.h"
   #endif

   #ifndef __MATH__
      #include "math.h"
   #endif

   #ifndef __STDLIB__
      #include "stdlib.h"
   #endif

   #ifndef __CTYPE__
      #include "ctype.h"
   #endif

   #ifndef _CONSTS_
      #include "novascon.h"
   #endif


/*
   Structures.
*/

/*
   struct fk5_entry: J2000.0 catalog data for a star.

   starname[9]        = name of star
   starnumber         = integer identifier assigned to star
   ra                 = mean right acsension, hours.
   dec                = mean declination, degrees.
   promora            = proper motion in RA, seconds per century.
   promodec           = proper motion in declination, arcsec per
                        century.
   parallax           = parallax, arcsec.
   radialvelocity     = radial velocity, km/sec.
   visualmag          = visual magnitude.
*/

   typedef struct
   {
      char starname[9];
      short int starnumber;
      double ra;
      double dec;
      double promora;
      double promodec;
      double parallax;
      double radialvelocity;
      double visualmag;
   } fk5_entry;

/*
   struct site_info: Observer's location.

   latitude           = geodetic latitude in degrees; north positive.
   longitude          = geodetic longitude in degrees; east positive.
   height             = height of the observer in meters.
*/

   typedef struct
   {
      double latitude;
      double longitude;
      double height;
   } site_info;


/*
   Define constants.
*/

   #define BARYC  0
   #define HELIOC 1

   #ifndef _CONSTS_
      #include "novas_consts.h"
   #endif


/*
   Function prototypes
*/

   short int app_star (double tjd, short int earth, fk5_entry *star, 

                       double *ra, double *dec);

   short int topo_star (double tjd, short int earth, double deltat,
                        fk5_entry *star, site_info *location, 

                        double *ra ,double *dec);

   short int app_planet (double tjd, short int planet, short int earth,

                         double *ra, double *dec, double *dis);

   short int topo_planet (double tjd, short int planet, short int earth,
                          double deltat, site_info *location,

                          double *ra, double *dec, double *dis);

   short int virtual_star (double tjd, short int earth, fk5_entry *star,

                           double *ra,double *dec);

   short int virtual_planet (double tjd, short int planet,
                             short int earth,

                             double *ra, double *dec, double *dis);

   short int local_star (double tjd, short int earth, double deltat,
                         fk5_entry *star, site_info *location,

                         double *ra, double *dec);

   short int local_planet (double tjd, short int planet,
                           short int earth, double deltat,
                           site_info *location,

                           double *ra, double *dec, double *dis);

   short int astro_star (double tjd, short int earth, fk5_entry *star,

                         double *ra, double *dec);

   short int astro_planet (double tjd, short int planet,
                           short int earth,

                        double *ra, double *dec, double *dis);

   short int mean_star (double tjd, short int earth, double ra,
                        double dec,

                        double *mra, double *mdec);

   short int get_earth (double tjd, short int earth,

                        double *tdb, double *bary_earthp,
                        double *bary_earthv, double *helio_earthp,
                        double *helio_earthv);

   void sidereal_time (double julianhi, double julianlo, double ee,

                       double *gst);

   void proper_motion (double tjd1, double *pos1, double *vel1,
                       double tjd2,

                       double *pos2);

   void geocentric (double *pos, double *earthvector,

                    double *pos2, double *lighttime);

   short int aberration (double *pos, double *vel, double lighttime,

                         double *pos2);

   short int precession (double tjd1, double *pos, double tjd2,

                         double *pos2);

   short int vector2radec (double *pos,

                           double *ra, double *dec);

   void pnsw (double tjd, double gast, double x, double y, double *vece,

              double *vecs);

   void angle2vector (double ra, double dec, double dist,

                      double *vector);

   void starvectors (fk5_entry *star,

                     double *pos, double *vel);

   short int calcnutation (double tdbtime,

                           double *longnutation, double *obliqnutation);

   short int nutate (double tjd, short int fn1, double *pos,

                     double *pos2);

   void convert_tdb2tdt (double tdb,

                         double *tdtjd, double *secdiff);

   short int sun_field (double *pos, double *earthvector,

                        double *pos2);

   void earthtilt (double tjd,

                   double *mobl, double *tobl, double *eqeq,
                   double *psi, double *eps);

   void terra (site_info *locale, double st,

               double *pos, double *vel);

   void spin (double st, double *pos1,

              double *pos2);

   void wobble (double x, double y, double *pos1,

               double *pos2);

   short int solarsystem (double tjd, short int body, short int origin, 

                          double *pos, double *vel);

#endif
