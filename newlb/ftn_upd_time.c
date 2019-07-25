#include <sys/types.h>
#include <sys/stat.h>

/* time should be delcared integer*4 in caller */

ftn_upd_time___(path,time,ierr,len)
char *path;
int len,*ierr;
long *time;
{
     struct stat sb;

     if(stat(path, &sb)==-1) {
        *ierr=-1;
        return;
     }
     *time=sb.st_mtime;
     *ierr=0;
     return;
}
