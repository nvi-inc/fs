#include <math.h>

#define MAX_PAR 3

double ftau(iwhich, x, par, npar)
int *iwhich, *npar;
double *x, par[MAX_PAR];
{
  double res;
  int i;

/*    y=a+Polynominal in first coordinate */

  if(*iwhich==0) {
    res=par[0]+par[2]*(1.0-exp(-par[1]**x));
  } else if(*iwhich==1) {
    res=1.0;
  } else if(*iwhich==2) {
    res = par[2]*exp(-par[1]**x)**x;
  } else
    res=0.0;
  
  return res;
}

