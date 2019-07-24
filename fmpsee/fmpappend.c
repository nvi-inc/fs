#include <stdio.h>
#include <unistd.h>

int fmpappend_(dcb,error)

FILE **dcb;
int *error;

{
  *error = fseek(*dcb,0L,SEEK_END);
  return(*error);
}
