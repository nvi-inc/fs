#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpreadxx_(dcb,error,xx)

  FILE **dcb;
  double *xx;
  int *error;
{

  *error = fscanf(*dcb,"%lf",xx);
  return(*error);
}
