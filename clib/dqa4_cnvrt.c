/* parity command utilities to support vlba drives and racks */

#include <string.h>
#include <sys/types.h>

void dqa4_cnvrt(ibuf,jfrms,jperr,jsync,ierr)
char *ibuf;               /* string to decode */
long jfrms[2];            /* returned frames errors */
long jperr[2];            /* returned parity errors */
long jsync[2];            /* returned re-sync counts */
int *ierr;
{
  long jrsyn[2];
  long jnsyn[2];
  long jcrc[2];
  int icount;

  icount=sscanf(ibuf,"dqa %x %x %x %x %x %x %x %x %x %x",
		jfrms+0,jperr+0,jnsyn+0,jrsyn+0,jcrc+0,
		jfrms+1,jperr+1,jnsyn+1,jrsyn+1,jcrc+1);

  if(icount == 10)
    *ierr=0;
  else {
    icount=sscanf(ibuf,"dq %x %x %x %x %x %x %x %x %x %x",
		  jfrms+0,jperr+0,jnsyn+0,jrsyn+0,jcrc+0,
		  jfrms+1,jperr+1,jnsyn+1,jrsyn+1,jcrc+1);
    if(icount == 10)
      *ierr=0;
    else
      *ierr=-1;
  }

  jsync[0]=jrsyn[0];
  jsync[1]=jrsyn[1];

  return;
}

