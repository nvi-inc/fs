#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpwriteyy_(dcb,error,yy)

  FILE **dcb;
  float *yy;
  int *error;
{
  int i,c;

  *error = 0;

  *error = fprintf(*dcb,"%f\n",*yy);

  return(*error);
}
