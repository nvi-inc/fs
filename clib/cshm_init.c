/* initialization fro "C" shared memory area */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void cshm_init()
{
  int i;

  for (i=0; i< 32; i++)
    shm_addr->vform.codes[i]=-1;

  shm_addr->vform.mode = -1;
  shm_addr->vform.tape_clock = -1;
  shm_addr->vform.enable.high = 0;  
  shm_addr->vform.enable.low  = 0;
  shm_addr->vform.enable.system = 0;
  shm_addr->vform.last = 1;

  shm_addr->bit_density = -1;

  shm_addr->systracks.track[0]=0;
  shm_addr->systracks.track[1]=1;
  shm_addr->systracks.track[2]=34;
  shm_addr->systracks.track[3]=35;

  return;
}

