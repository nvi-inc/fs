/* mk5dbbcd_pfb.c make list of bbc detectors needed for DBBC_PFB rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk5dbbcd_pfb(itpis)
int itpis[MAX_DBBC_PFB];
{
  int vc,i;

  if(shm_addr->mk5b_mode.mask.state.known == 0 ||
     shm_addr->dbbcform.mode!=0)
    return;

  for(i=0;i<16;i++) {
    if(shm_addr->mk5b_mode.mask.mask & (0x3ULL << (i*2)) &&
       0 != shm_addr->dbbc_vsix[0].core[i])
      itpis[(shm_addr->dbbc_vsix[0].core[i]-1)*16+
	    shm_addr->dbbc_vsix[0].chan[i]] = 1;

    if(shm_addr->mk5b_mode.mask.mask & (0x3ULL << (32+i*2)) &&
       0 != shm_addr->dbbc_vsix[1].core[i]) {
      itpis[(shm_addr->dbbc_vsix[1].core[i]-1)*16+
	    shm_addr->dbbc_vsix[1].chan[i]] = 1;
    }
  }
}

