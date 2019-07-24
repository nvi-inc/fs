/* equn

   Equation of equinoxes to about 0.1 s of time, extracted
   from J. Ball's MOVE routine. Copied from EQUN in POLB.
   NRV 920309
*/

#include <math.h>

void equn(nyrf,nday,eqofeq)
int nyrf;         /* year since 1900 */
int nday;         /* day of year     */
double *eqofeq;   /* equation of equinoxes */

{
  double a1,a,t,aomega,arg,dlong,doblq;

  a1=nday;
  a=nyrf;
  t = (a + a1/365.2421988)/100.0;

/* Nutation  */

  aomega=259.183275-1934.142*t;
  arg=aomega*0.0174532925;
  dlong= -8.3597e-5*sin(arg);

  *eqofeq=dlong*0.917450512;
}

