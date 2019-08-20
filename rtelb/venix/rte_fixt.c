/* rte_fixt.c - calculate offset to add to time */

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_fixt( poClock, plCentiSec)
time_t *poClock;
int *plCentiSec;
{
     if(shm_addr->time.model != 'n') {
     	int iIndex;
     	int lEpoch, lAddHs;

        iIndex = 01 & shm_addr->time.index;
	lAddHs = shm_addr->time.offset[iIndex];
     	lEpoch = shm_addr->time.epoch[iIndex];

     	if (lEpoch && shm_addr->time.model == 'r') {
                float fAdd;
       		fAdd = shm_addr->time.rate[iIndex] * (*plCentiSec-lEpoch);
                lAddHs += (fAdd + 0.5);
        }

        *plCentiSec += lAddHs;
     }

    *poClock = (*plCentiSec/100) + shm_addr->time.secs_off;

    *plCentiSec %= 100;

    return;
}
