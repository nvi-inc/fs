#include <signal.h>
#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

int gooff(lonoff,latoff,axis,nwait,ierr)
     double lonoff,latoff;
     char *axis;
     int nwait,*ierr;
{

  if(strcmp(axis,"azel")==0) {
    shm_addr->AZOFF=lonoff;
    shm_addr->ELOFF=latoff;
  } else if(strcmp(axis,"hadc")==0) {
    shm_addr->RAOFF=-lonoff;
    shm_addr->DECOFF=latoff;
  } else if(strcmp(axis,"xyns")==0||strcmp(axis,"xyew")==0) {
    shm_addr->XOFF=lonoff;
    shm_addr->YOFF=latoff;
  } else {
    *ierr=-60;
    return -1;
  }

  if(antcn(2,ierr))
    return -1;

  if(onsor(nwait,ierr))
    return -1;

  return 0;
}
