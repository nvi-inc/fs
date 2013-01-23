/* rte_ticks.c - return raw system ticks in clock HZ */

#include <stdlib.h>
#include <sys/times.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_ticks(lRawTicks)
long *lRawTicks;
{
     struct tms buffer;
     clock_t ticks;
     
     ticks=times(&buffer);
     if(ticks == (clock_t) -1) {
       perror("using times()");
       exit(-1);
     }
     *lRawTicks=(signed) ((unsigned long) ticks - shm_addr->time.ticks_off);

     return;
}
     
