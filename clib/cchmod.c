#include <sys/types.h>
#include <sys/stat.h>

void cchmod(filename,permissions,ilen,error,flen)
char *filename;
int *permissions;
int *ilen;
int *error;
int flen;
{
    char chname[64];
    int i;

    *error = 0;
    if ((flen < 0) || (flen > 64)){
      *error = -1;
      return;
    }

    strncpy(chname,filename,flen);
    i = *ilen;
    while (i >=0 && chname[i] == ' ') i=i-1;
    chname[i+1] = '\0';

    chmod(chname,*permissions);
}
