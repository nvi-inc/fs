#include <math.h>
#include <stdio.h>

main()
{
  double x[8],y[8];
  int i;
  
  for(i=0;i<8;i++) {
    x[i]=cos(2*M_PI*i/8);
    y[i]=sin(2*M_PI*i/8);
    printf(" i %d x %f y %f\n",i,x[i],y[i]);
  }
  FFT(1,3,x,y);
  for(i=0;i<8;i++) {
    printf(" i %d x %f y %f\n",i,x[i],y[i]);
  }
  FFT(1,3,x,y);
  for(i=0;i<8;i++) {
    printf(" i %d x %f y %f\n",i,x[i],y[i]);
  }

}
