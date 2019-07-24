#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int writestr_(dcb,error,cbuf,slen,len)

  FILE **dcb;
  char *cbuf;
  int *error,len,*slen;
{
  int i,c;

  *error = 0;

  for (i=0; i < *slen; i++) {
    c = cbuf[i];
    if (EOF == fputc(c,*dcb)) {
      *error=-1;
      printf("the length printed before error is %d\n",i);
      return(*error);
    }
  }

  if (EOF == fputc('\n',*dcb)) {
    *error=-2;
    return(*error);
  }

  return(*slen);
}
