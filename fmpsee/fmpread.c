#include <stdio.h>
#include <string.h>
#define MAX_LINE 256

int fmpread_(dcb,error,buf,len)
FILE **dcb;
char *buf;
int *error,*len;
{
  int clen,i;
  char *c;

  buf[0]=0;
  c = fgets(buf,*len,*dcb);

  clen=strlen(buf);
  buf[clen]=' ';
  if(clen>0 && buf[clen-1]=='\n')
    buf[--clen]=' ';
  else if(clen > 0){
    char ch=fgetc(*dcb);
    while (ch!= EOF && ch!= '\n')
      ch=fgetc(*dcb);
  }

  if(c == NULL) {
    if(clen 	== 0)
      return -1;
  }
    return clen;
}
