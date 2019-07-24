#include <math.h>

static double equn();

void sider(it,iyear,sidto)
int it[6], iyear;
double *sidto;
{
  double ut, fract, eqofeq;
  int iy;
  int mjd, julda();
  void sidtm();

  ut = (double)it[0]*.01 + (double)it[1] + (double)it[2]*60.0 
        + (double)it[3]*3600.0;
  iy=iyear-1900;
  mjd=julda(it[4],iy);
  sidtm(mjd,sidto,&fract);
  eqofeq = equn(iy,it[4]);
  *sidto = *sidto+fract*ut+eqofeq;
  *sidto = fmod(*sidto,(2.0*M_PI));

  if (*sidto < 0.0) *sidto=*sidto+(2.0*M_PI);

}

int julda(iday,iyear)

/*
 *  RETURNS JD-2440000
 *  FROM GIVEN DAY AND YEAR SINCE 1900 (GREGORIAN CALENDAR) 
*/

int iday, iyear;

{
  int iyr;
  int julda;

  julda = 0; 

  iyr=iyear/4;

  if (iyear == iyr*4) 
    iyr=iyr-1;

  julda = (-24980 +365*iyear) + (iday+iyr);
  
  return(julda);

}

void sidtm(jd,sider,fract)

  int jd;
  double *sider;
  double *fract;

{
  double tdub;
  int jul;

/*
 *  JD = INPUT JULIAN DAY NUMBER AS COMPUTED BY "JULDA" 
 *               =  (JD-2440000)  
 *    sider = OUTPUT MEAN SIDEREAL TIME AT 0 HR UT 
 *       = MEAN SIDEREAL TIME AT JULIAN DATE JD-.5 (IN RADIANS) 
 *    FRACT = OUTPUT RATIO BETWEEN MEAN SIDEREAL TIME AND UNIVERSAL TIME 
 *            MULTIPLIED BY TWOPI DIVIDED BY 86,400  
*/
  tdub = jd;
  tdub = tdub + 24980.0;
  tdub = tdub - 0.50; 

  *fract = 7.292115855e-5 + tdub * 1.1727115e-19;
  *sider = 1.73993589470 + tdub * (1.7202791266e-2 + tdub * 5.06409e-15);
  jul = *sider/(2.0 * M_PI);

  if (*sider < 0.0)
    jul = jul-1;

  tdub = (double)jul;

  *sider = *sider - (tdub * (2.0 * M_PI));

}

static double equn(nyrf,nday)

int nyrf, nday;

/*
 *  EQUATION OF EQUINOXES TO ABOUT 0.1 SECONDS OF TIME
 *
 *    NYRF = YEAR SINCE 1900
 *    NDAY = DAY OF YEAR
 *    EQOFEQ IS RETURNED EQUATION OF EQUINOXES
*/

{
  double equn;
  double tprec, aomega, arg;
  double dlong, doblq;

  tprec = (nyrf+nday/365.24219880)/100.0;
 
/*   NUTATION  */
 
  aomega = 259.1832750 - 1934.1420*tprec;
  arg = aomega*0.01745329250;
  dlong = -8.3597e-5 * sin(arg);
  doblq = 4.4678e-5 * cos(arg);
  equn = dlong * 0.9174505120;

  return(equn);

}
