/* mk4bbcd.c make list of bbc detectors needed for Mark IV rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk4bbcd(itpis)
int itpis[28];
{
  int vc,i;

  for (i=0;i<64;i++) {
    if ((i<32 && (shm_addr->form4.enable[0] & (1<<i))) ||
	(i>31 && (shm_addr->form4.enable[1] & (1<<(i-32))))) {
      vc=shm_addr->form4.codes[i]&0xF;
      if(-1 < vc && vc <14) {
	int sb=0;
	if(0==(shm_addr->form4.codes[i]&0x10))
	  sb=1;
	itpis[vc+14*sb]=1;
      }
    }
  }
}

