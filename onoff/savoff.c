#include <signal.h>
#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

savoff(xoff,yoff,azoff,eloff,haoff,decoff)
double *xoff,*yoff,*azoff,*eloff,*haoff,*decoff;
{

  *xoff=shm_addr->XOFF;
  *yoff=shm_addr->YOFF;
  *azoff=shm_addr->AZOFF;
  *eloff=shm_addr->ELOFF;
  *haoff=-shm_addr->RAOFF;
  if(*haoff==-0.0)
    *haoff=0.0;
  *decoff=shm_addr->DECOFF;

}
