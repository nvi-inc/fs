#include <sys/types.h>
#include <math.h>
#include <time.h>
#include <math.h>
#include <stdio.h>
#include "mparm.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void azel(it, alat, wlong, rad, dec, azim, elev)

double alat, wlong, rad, dec;
float *azim, *elev;
int it[6];       /* times from system  */

{
   double slat, clat, sin2, cin2, sidt, tlst;
   double had, sha, cha;
   double out1, out2;
   double xxx, xxx2;
   void sider(); 
  
/*
 *  Compute Julian day. 
 *  Calculate sidereal times, ha.
 *  Calculate az, el.
*/ 
   slat = sin(alat);
   clat = cos(alat);

   sin2 = sin(dec);
   cin2 = cos(dec);
   sider(it,it[5],&sidt);

   tlst = sidt-wlong;

   had = tlst-rad;

   if (had > 0.0) had=fmod(had,(2.0*M_PI));
   if (had < 0.0) had=fmod(had,(-2.0*M_PI));
   if (had < -M_PI) had=had+(2.0*M_PI);
   if (had >  M_PI) had=had-(2.0*M_PI);
   sha = sin(had);
   cha = cos(had);

   xxx = slat*sin2+clat*cin2*cha;

   xxx2 = sqrt(fabs(1. - xxx*xxx));
   out2 = atan(xxx/xxx2);
/*      dasin(x) = datan2z(x,dsqrt(dabs(1.-x*x)))
*/
   out1 = atan((-cin2*sha)/(clat*sin2-slat*cin2*cha));

   if (out1 < 0.0) out1 = out1+(2.0*M_PI);

 *azim = out1 * 180.0/M_PI;
 *elev = out2 * 180.0/M_PI;

}
