#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpreadstr_(dcb,error,cbuf,len)
FILE **dcb;
char *cbuf;
int *error,len;
{
  int clen,i;
  char *c;

  cbuf[0]=0;
  c = fgets(cbuf,len,*dcb);

  clen=strlen(cbuf);
  if(clen>0 && cbuf[clen-1]=='\n') {
    cbuf[--clen]=0;
  }

  if(c == NULL) {
    if(clen 	== 0) {
      for (i=clen;i<len;i++)
	cbuf[i]=' ';
      return -1;
    }
  }
  for (i=clen;i<len;i++)
    cbuf[i]=' ';

    return clen;
}
