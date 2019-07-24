#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpwritexx_(dcb,error,xx)

  FILE **dcb;
  double *xx;
  int *error;
{
  int i,c;

  *error = 0;

  *error = fprintf(*dcb,"%lf\n",*xx);

  return(*error);
}
