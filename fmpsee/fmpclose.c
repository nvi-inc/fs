#include <stdio.h>
#include <errno.h>

void fmpclose_(dcb,error)

  FILE **dcb;
  int *error;
{

  *error=0;

  if(*dcb == NULL)
	return;
  if (EOF == fclose(*dcb) && errno != EBADF) {
    *error=-1;
  }
  else 
    *error=0;

  *dcb=NULL;

  return;
}
