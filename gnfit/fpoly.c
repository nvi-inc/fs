#define MAX_PAR 10

double fpoly(iwhich, x, par, npar)
int *iwhich, *npar;
double *x, par[MAX_PAR];
{
  double res;
  int i;

/*    Polynominal in first coordinate */

  if(*iwhich==0) {
    res=0.0;
    for (i=*npar-1;i>-1;i--)
      res=res**x+par[i];
  } else if(*iwhich>=1) {
    res=1.0;
    for (i=1;i<*iwhich;i++)
      res=res**x;
  } else
    res=0.0;
  
  return res;
}

