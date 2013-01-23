#include <stdio.h>

void fc_putln2__( string, len)
char *string;
int *len;
{
  if(*len>1 && string[*len-1]=='_')
    fprintf(stderr,"%.*s",*len-1,string);
  else if(*len>0)
    fprintf(stderr,"%.*s\n",*len,string);
}
