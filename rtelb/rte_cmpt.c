/* rte_cmpt.c - calculate computer time */

#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_cmpt( poClock, plCentiSec)
time_t *poClock;
long *plCentiSec;
{
     struct timeval tv;
     long lRawTime;

     if(0!= gettimeofday(&tv, NULL)) {
       perror("getting timeofday, fatal\n");
       exit(-1);
     }
     *poClock=tv.tv_sec;
     *plCentiSec=tv.tv_usec/10000;

     return;
}
