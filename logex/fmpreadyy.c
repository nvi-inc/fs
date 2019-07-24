#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpreadyy_(dcb,error,yy)

  FILE **dcb;
  float *yy;
  int *error;
{

  *error = fscanf(*dcb,"%f",yy);
  return(*error);
}
