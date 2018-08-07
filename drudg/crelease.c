#include <string.h>
#include <stdio.h>

void crelease_(char *lstring, int llen)
{

int i,j;

#define xstr(a) str(a)
#define str(a) #a
#define RELV xstr(RELEASE)

  strncpy(lstring,RELV,llen);
  lstring[llen-1]=0;
  j=strlen(lstring);
  for(i=j;i<llen-1;i++)
    lstring[i]=' ';

  return;
}
