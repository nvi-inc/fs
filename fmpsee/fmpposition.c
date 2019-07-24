#include <stdio.h>

int fmpposition_(dcb,error,record,position)

FILE **dcb;
int *error;
long *record,*position;

{
  *record = ftell(*dcb);
  return(*error);
}
