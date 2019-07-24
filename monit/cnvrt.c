/* cnvrt

   Convert from one coordinate system to another, depending
   on the input mode. All angle arguments are radians.
   Copied from the FORTRAN.
   NRV 920311

   imode     Input      Output
   -----    -------    --------
     1      ra/dec     az/el
     2      az/el      ra/dec
     3      ra/dec     x/y NS
     4      x/y NS     az/el
     5      az/el      x/y NS
     6      x/y NS     ha/dec
     7      x/y NS     ra/dec
     8      ha/dec     x/y NS
     9      ha/dec     az/el
    10      az/el      ha/dec
*/

#include <math.h>
#include <stdio.h>
#include "dpi.h"
#include "stparams.h"

void sider();

cnvrt(mode,ain1,ain2,out1,out2,it,alat,wlong)
int mode;               /* type of conversion */
double ain1, ain2;      /* input angles       */
double *out1, *out2;    /* output angles      */
int it[6];              /* standard rte time  */
double alat,wlong;      /* lat,lon of station */

{
  double ha,sidt,tlst;
  double slat,clat,sin1,sin2,cin1,cin2,sha,cha;
/*
  fprintf(stdout,"cnvrt: mode=%d, in=%f,%f\n",
  mode,ain1*RAD2DEG,ain2*RAD2DEG);
  fprintf(stdout,"   it=%d/%d-%d:%d:%d\n",it[5],it[4],it[3],it[2],it[1]);
*/
  slat = sin(alat);
  clat = cos(alat);
  sin1 = sin(ain1);
  sin2 = sin(ain2);
  cin1 = cos(ain1);
  cin2 = cos(ain2);
  sider(it,it[5],&sidt);
/*
  fprintf(stdout,"sidt= %f\n",sidt*RAD2DEG);
*/
  tlst = sidt - wlong;
  ha = tlst - ain1;
/*
  fprintf(stdout,"ha= %f\n",ha*RAD2DEG);
*/
  ha = (ha >  0.0) ? fmod(ha,DTWOPI) : fmod(ha,-DTWOPI);
  ha = (ha < -DPI) ? ha+DTWOPI    : ha;
  ha = (ha >  DPI) ? ha-DTWOPI    : ha;
  sha = sin(ha);
  cha = cos(ha);

  switch (mode) {

    case 1:               /* ra/dec --> az/el */
      *out2 = asin(slat*sin2 + clat*cin2*cha);
      *out1 = ATAN2Z(-cin2*sha,clat*sin2-slat*cin2*cha);
      if (*out1 < 0.0)
        *out1 += DTWOPI;
      break;

    case 2:               /* az/el --> ra/dec */
      ha = -ATAN2Z(cin2*sin1,sin2*clat-cin2*cin1*slat);
      *out1=tlst-ha;
      if (*out1 < 0.0) *out1 += DTWOPI;
      if (*out1 > DTWOPI) *out1 -= DTWOPI;
      *out2 = asin(cin2*cin1*clat+sin2*slat);
      break;

    case 3:               /* ra/dec --> x/y NS */
      *out1 = ATAN2Z(-cin2*sha,slat*sin2+clat*cin2*cha);
      *out2 = asin(clat*sin2-slat*cin2*cha);
      break;

    case 4:               /* x/y NS --> az/el  */
      *out1 = ATAN2Z(sin1*cin2,sin2);
      if (*out1 < 0.0) *out1 += DTWOPI;
      *out2 = asin(cin2*cin1);
      break;

    case 5:               /* az/el --> x/y NS  */
      *out1 = ATAN2Z(cin2*sin1,sin2);
      *out2 = asin(cin2*cin1);
      break;

    case 6:               /* x/y NS --> ha/dec */
      *out1 = -ATAN2Z(cin2*sin1,cin2*cin1*clat-sin2*slat);
      *out2 = asin(sin2*clat+cin2*cin1*slat);
      break;

    case 7:               /* x/y NS --> ra/dec */
      ha = -ATAN2Z(cin2*sin1,cin2*cin1*clat-sin2*slat);
      *out1=tlst-ha;
      if (*out1 < 0.0) *out1 += DTWOPI;
      if (*out1 > DTWOPI) *out1 -= DTWOPI;
      *out2 = asin(sin2*clat+cin2*cin1*slat);
      break;

    case 8:               /* ha/dec --> x/y NS */
      *out1 = ATAN2Z(-cin2*sin1,slat*sin2+clat*cin2*cin1);
      *out2 = asin(clat*sin2-slat*cin2*cin1);
      break;

    case 9:               /* ha/dec --> az/el  */
      *out2 = asin(slat*sin2+clat*cin2*cin1);
      *out1 = ATAN2Z(-cin2*sin1,clat*sin2-slat*cin2*cin1);
      if (*out1 < 0.0) *out1 += DTWOPI;
      break;

    case 10:              /* az/el --> ha/dec  */
      *out1 = ATAN2Z(cin2*sin1,sin2*clat-cin2*cin1*slat);
      if (*out1 < -DPI) *out1 += DTWOPI;
      if (*out1 >  DPI) *out1 -= DTWOPI;
      *out2 = asin(cin2*cin1*clat+sin2*slat);
  }
/*
  printf("cnvrt: out=%f %f\n",*out1*RAD2DEG,*out2*RAD2DEG);
*/
}
