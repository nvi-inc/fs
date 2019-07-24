#include <stdio.h>
#include <unistd.h>

int fmpsetpos_(dcb,error,record,position)

FILE **dcb;
int *error;
long *record,*position;

{
  *error = fseek(*dcb,*record,SEEK_SET);
  return(*error);
}
