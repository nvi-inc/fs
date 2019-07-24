#include <stdio.h>
#include <sys/types.h>

int fmpreadxx_(dcb,error,xx)

  FILE **dcb;
  double *xx;
  int *error;
{

  *error = fread((char *) xx,sizeof(short),14,*dcb);
  return(*error);
}
