#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int get_flux();

get_flux_file(ierr)
     int *ierr;
{
  char outbuf[80];
  int freq, icount;
  FILE *idum;

  strcpy(outbuf,FS_ROOT);
  strcat(outbuf,"/control/flux.ctl");
  *ierr=get_flux(outbuf,&shm_addr->flux);
  
  return;

}









