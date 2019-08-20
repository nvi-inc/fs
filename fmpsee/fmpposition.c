#include <stdio.h>

int fmpposition_(dcb,error,record,position)

FILE **dcb;
int *error;
int *record,*position;

{
  if(*dcb==NULL)
    return 0;
  *record = ftell(*dcb);
  return(*error);
}
