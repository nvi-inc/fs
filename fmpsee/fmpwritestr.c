#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpwritestr_(dcb,error,cbuf,len)

  FILE **dcb;
  char *cbuf;
  int *error,len;
{
  int i,c;

  *error = 0;

  for (i=0; i < len; i++) {
    c = cbuf[i];
    if (EOF == fputc(c,*dcb)) {
      *error=-1;
      return(*error);
    }
  }

  if (EOF == fputc('\n',*dcb)) {
    *error=-2;
    return(*error);
  }

  return(len);
}
