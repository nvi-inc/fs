/* lbaifpd.c make list of ifp detectors needed for LBA rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void lbaifpd(itpis)
int itpis[2*MAX_DAS];
{
   int i;

   for(i=0; i<2*shm_addr->n_das; i++)
	if (shm_addr->das[i/2].ifp[i%2].track[0] != -1 ||
	    shm_addr->das[i/2].ifp[i%2].track[1] != -1)
		itpis[i] = 1;
}

