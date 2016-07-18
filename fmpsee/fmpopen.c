#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#define MAX_NAME 64

extern int fmperror_standalone;

void fmpopen_(dcb,filename,error,options,dcbb,len,leno)

  FILE **dcb;
  char *filename,*options;
  int *error,len,leno;
  int *dcbb;
{
  char iname[MAX_NAME+1],*s1;
  char iopt[MAX_NAME+1],*so;
  size_t n,no;

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
    if(fmperror_standalone)
      fprintf(stderr,"fmpopen: %s, %s\n",iname,strerror(errno));
    else {
      char mess[MAX_NAME+20];
      strcpy(mess,"Opening file: ");
      strcat(mess,iname);
      logite(mess,-1,"fm");
    }
    *error=-errno;
  }
  return;
}
