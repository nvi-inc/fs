#include <unistd.h>
#include <errno.h>

int fc_readlink__( path,link,ierr,lenp,lenl)
char	path[ ],link[ ];	
int     *ierr, lenp,lenl;
{
  int iret;

  iret=readlink(path,link,lenl);

  if(iret<0)
    *ierr=errno;

  return iret;
}
