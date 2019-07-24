#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#define MAX_NAME 64

void fmpopen_(dcb,filename,error,options,dcbb,len,leno)

  FILE **dcb;
  char *filename,*options;
  int *error,len,leno;
  int *dcbb;
{
  char iname[MAX_NAME+1],*s1;
  char iopt[MAX_NAME+1],*so;
  size_t n,no;

  printf(" filename %64.64s options %64.64s len %d leno %d\n\n",
         filename,options,len,leno);
  *error=0;
  n = len;
  s1=strncpy(iname,filename,n);
  iname[len]='\0';

  s1=strchr(iname,' ');
  if(s1 != NULL) *s1='\0';

  no= leno;
  so=strncpy(iopt,options,no);
  iopt[leno]='\0';

  so=strchr(iopt,' ');
  if(so != NULL) *so='\0';

  if ((*dcb = fopen(iname, iopt)) == NULL) {
    printf("fmpopen: can't open %s\n", iname);
    perror("");
    *error=-1;
  }
  return;
}
