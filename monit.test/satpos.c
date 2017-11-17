#include <string.h>

#include "../include/params.h" /* FS parameters            */
#include "../include/fs_types.h" /* FS header files        */
#include "../include/fscom.h"

extern struct fscom *shm_addr;

satpos(itcmd,azcmd,elcmd)
     int itcmd[6];
     double *azcmd,*elcmd;
{
  int i;
  long seconds;

  rte2secs(itcmd,&seconds);
  if(seconds < shm_addr->ephem[0].t) {
    *azcmd=shm_addr->ephem[0].az;
    *elcmd=shm_addr->ephem[0].el;
  }  else if(seconds >= shm_addr->ephem[MAX_EPHEM-1].t) {
    *azcmd=shm_addr->ephem[MAX_EPHEM-1].az;
    *elcmd=shm_addr->ephem[MAX_EPHEM-1].el;
  }  else  {
    for (i=0;i<MAX_EPHEM;i++)
      if(seconds == shm_addr->ephem[i].t) {
	*azcmd=shm_addr->ephem[i].az;
	*elcmd=shm_addr->ephem[i].el;
	break;
      }
    if(i==MAX_EPHEM) {
      *azcmd=shm_addr->ephem[MAX_EPHEM-1].az;
      *elcmd=shm_addr->ephem[MAX_EPHEM-1].el;
    }
  }
}
