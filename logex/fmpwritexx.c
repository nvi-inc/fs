#include <stdio.h>
#include <sys/types.h>

int fmpwritexx_(dcb,error,xx)

  FILE **dcb;
  double *xx;
  int *error;
{
  int i,c;

  *error = 0;

  *error = fwrite((char *)xx,sizeof(short),14,*dcb);

  return(*error);
}
