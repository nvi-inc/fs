/* rte_sett.c - set FS and optionally system time */

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

/*
 * oFmClock - formatter time
 * oFmHs  - centiseconds to go with oFmClock
 * lCentiSec - raw cpu time corresponding to (oFmClock,oFmHs)
 * mode - 'cpu' to set cpu time
 *        'offset' to reset offset
 *        'rate'   to measure rate
 *
 * ierr non-zero only if mode is 's' and stime fails
 */

int rte_secs();

int rte_sett( oFmClock, iFmHs, lCentiSec, sMode)
time_t oFmClock;
int iFmHs;
int lCentiSec;
char *sMode;
{
    int iIndex, ierr;
    char model;

    iIndex = 01 & shm_addr->time.index;
    model = shm_addr->time.model;

    if (!strcmp(sMode,"cpu")) {
        rte_sleep(25);
        ierr=stime(&oFmClock);
        shm_addr->time.secs_off = rte_secs();
    } else {
       time_t oCpuClock;
       int iCpuHs;
       int lEpoch, lOffset, lDiffHs, lSpan;
       float fRate;

       oCpuClock=lCentiSec/100+shm_addr->time.secs_off;
       iCpuHs = lCentiSec % 100;
       lDiffHs = (oFmClock-oCpuClock)*100+iFmHs-iCpuHs;

       lEpoch = shm_addr->time.epoch[iIndex];
       fRate = shm_addr->time.rate[iIndex];
       lOffset = shm_addr->time.offset[iIndex];
       lSpan = shm_addr->time.span[iIndex];

       if(!strcmp(sMode,"offset")) {
                  	   /* don't update rate, but save the other stuff */
         lEpoch=lCentiSec;
         lOffset = lDiffHs;
       } else if (!strcmp(sMode,"rate") ) {
					/* update the rate */
         lSpan = lCentiSec-lEpoch;
         fRate=((double)(lDiffHs-lOffset))/lSpan;
       }

       iIndex = 01 & ~iIndex;
       shm_addr->time.rate[iIndex] = fRate;
       shm_addr->time.span[iIndex] = lSpan;
       shm_addr->time.offset[iIndex] = lOffset;
       shm_addr->time.epoch[iIndex] = lEpoch;
       shm_addr->time.index = iIndex;

       ierr=0;
    }

    return ierr;
}
