#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <errno.h>

#define MAX_NAME 65

ftn_purge__(name,ierr,len)
char *name;
int *ierr,len;
{
   char iname[MAX_NAME+1],*s1;
   size_t n;

   if(len > MAX_NAME) {    /* make sure the name will fit */
     *ierr=-2;
     return;
   }

   n=len;                  /* copy the name and NULL terminate */
   s1=strncpy(iname,name,n);
   iname[len]='\0';

   s1=strchr(iname,' ');    /* put a NULL in place of the first blank */
   if(s1 != NULL) *s1='\0';

   *ierr=unlink(iname);    /* do it */
   return;
}
void ftn_rename__(old,erro,new,errn,leno,lenn)
char *old,*new;
int *erro,*errn,leno,lenn;
{
   char oname[MAX_NAME+1],nname[MAX_NAME+1],*s1;
   size_t n;

   *erro=0;
   *errn=0;

   if(leno > MAX_NAME) {    /* make sure the name will fit */
     *erro=-2;
     return;
   }

   if(lenn > MAX_NAME) {    /* make sure the name will fit */
     *errn=-2;
     return;
   }

   /* fix old name */

   n=leno;                  /* copy the name and NULL terminate */
   s1=strncpy(oname,old,n);
   oname[leno]='\0';

   s1=strchr(oname,' ');    /* put a NULL in place of the first blank */
   if(s1 != NULL) *s1='\0';

   /* fix new name */

   n=lenn;                  /* copy the name and NULL terminate */
   s1=strncpy(nname,new,n);
   nname[lenn]='\0';

   s1=strchr(nname,' ');    /* put a NULL in place of the first blank */
   if(s1 != NULL) *s1='\0';

   *errn=link( oname, nname); /* make the new link */

   if(*errn != 0) {
     perror("ftn_rename:link");
     fflush(NULL);
     return;
   }

   *erro=unlink(oname);    /* unlink the old name */
   if(*erro != 0) {
     perror("ftn_rename:unlink");
     fflush(NULL);
     return;
   }

   return;
}
#define MAX_STRING  256

ftn_runprog__(in,ierr,len)
char *in;
int *ierr,len;
{
     char string[MAX_STRING+1],*s1;
     size_t n;

     if (len > MAX_STRING) {
        *ierr=-2;
        return;
     }

     n=len;                  /* copy the name and NULL terminate */
     s1=strncpy(string,in,n);
     string[len]='\0';

     *ierr=system(string);
     return;
}

/* time should be delcared integer*4 in caller */

ftn_upd_time__(path,time,ierr,len)
char *path;
int len,*ierr;
long *time;
{
     struct stat sb;
     char iname[MAX_NAME+1],*s1;
     size_t n;

     if(len > MAX_NAME) {    /* make sure the name will fit */
       *ierr=-2;
       return;
     }

     n=len;                  /* copy the name and NULL terminate */
     s1=strncpy(iname,path,n);
     iname[len]='\0';

     s1=strchr(iname,' ');    /* put a NULL in place of the first blank */
     if(s1 != NULL) *s1='\0';

     if(stat(iname, &sb)==-1) {
        *ierr=-1;
        return;
     }
     *time=(long) sb.st_mtime;
     *ierr=0;
     return;
}
