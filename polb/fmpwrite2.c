#include <stdio.h>
#include <string.h>

int fmpwrite2_(dcb,error,buf,len)

  FILE **dcb;
  int *error, *len;
  char *buf;
{
  int i;
  char nl='\n';

i = fwrite(buf,sizeof(char),*len-*len%2,*dcb);
i = fwrite(&nl,sizeof(char),1,*dcb);

return(*len);
}
