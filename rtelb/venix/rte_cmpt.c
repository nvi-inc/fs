/* rte_cmpt.c - calculate computer time */

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_cmpt( poClock, plCentiSec)
time_t *poClock;
int *plCentiSec;
{

    *poClock = (*plCentiSec/100) + shm_addr->time.secs_off;

    *plCentiSec %= 100;

    return;
}
