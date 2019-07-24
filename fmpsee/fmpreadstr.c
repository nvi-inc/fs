#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpreadstr_(dcb,error,cbuf,len)

  FILE **dcb;
  char *cbuf;
  int *error,len;
{
  int i,c,j;

  c = fgetc(*dcb);
  i = 0;
  while ((c !=EOF) && (c !='\n')) {
    cbuf[i]=c;
    ++i;
    c = fgetc(*dcb);
  }

  for (j=i;j<len;j++)
    cbuf[j]=' ';

  if (c == EOF) {
    cbuf[i]='\0';
    i = -1;
  }
 
  return(i);
}
