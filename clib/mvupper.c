#include <ctype.h>

void mvupper_(ibuf1,is1,ibuf2,is2,nc)
char *ibuf1,*ibuf2;
int *is1,*is2,*nc;
{
  int i;
  for(i=0;i<*nc;i++)
    ibuf1[*is1+i]=toupper(ibuf2[*is2+i]);
}
