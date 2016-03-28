#include <math.h>

main()
{
  double x[8],y[8];
  int i;
  
  for(i=0;i<8;i++) {
    x[i]=cos(2*M_PI/8);
    y[i]=sin(2*M_PI/8);
    print(" i %d x %f y %f\n",i,x[i],y[i]);
  }
