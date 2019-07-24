#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

uptime(path,time,ierr)
char *path;
int *ierr;
long *time;
{
     struct stat sb;

     errno = 0;
     if(stat(path, &sb)==-1) {
        *ierr=-1;
        return;
     }
     *time=sb.st_mtime;
     if(errno==ENOENT) *time=0;
     *ierr=0;
     return;
}
