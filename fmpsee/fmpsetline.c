#include <stdio.h>
#include <unistd.h>
#include <string.h>

int fmpsetline_(dcb,error,position)

FILE **dcb;
int *error;
int *position;

{
  int readstr();
  int i;

  *error = 0;

  *error = fseek(*dcb,0L,SEEK_SET);
  if (*error <0) return(*error);

  i=0;
  while (i < *position) {
    i++;
    *error = readstr(dcb);
    if (*error < 0) return(*error);
  }
  return(i);
}

int readstr(dcb)

  FILE **dcb;
{
  int i,c;

  i = 0;
  c = fgetc(*dcb);
  while ((c !=EOF) && (c !='\n')) {
    c = fgetc(*dcb);
  }

  if (c == EOF) {
    i = -1;
  }
 
  return(i);
}
