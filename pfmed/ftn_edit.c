#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>

#define MAX_NAME 64
#define MAX_STRING  256

ftn_edit_(iname,ierr,ichange,len)
char *iname;
int *ierr,*ichange,len;
{
     struct stat sb;
     long tmone, tmtwo;
     int error;
     char string[MAX_STRING+1],*s1;
     char path[MAX_STRING+1],*s2;
     size_t n;

     if (len > MAX_STRING) {
        *ierr=-2;
        return;
     }

     n = len;
     s1=strcpy(string,"vi ");
     s1=strncat(string,iname,n);
     string[len+3]='\0';

     s2=strncpy(path,iname,n);
     path[len]='\0';
     s2=strchr(path,' ');    /* put a NULL in place of the first blank */
     if(s2 != NULL) *s2='\0';

     if(stat(path, &sb)==-1) {
        *ierr=-1;
        return;
     }
     tmone=(long) sb.st_mtime;

     *ierr=system(string);

     if(stat(path, &sb)==-1) {
        *ierr=-1;
        return;
     }
     tmtwo=(long) sb.st_mtime;

     if (tmone == tmtwo)
       *ichange=0;
     else
       *ichange=1;

     return;
}
