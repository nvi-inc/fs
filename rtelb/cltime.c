#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include <fcntl.h>
#include <termio.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

struct fscom *fs;

main()
{

    int index;
    setup_ids();    /* attach to the shared memory */

    fs = shm_addr;
    index=0;

            fs->time.offset[index]=0;
            fs->time.rate[index]=0;
            fs->time.epoch[index]=0;
            fs->time.epochhs[index]=0;
    index=1-index;
            fs->time.offset[index]=0;
            fs->time.rate[index]=0;
            fs->time.epoch[index]=0;
            fs->time.epochhs[index]=0;
    fs->time.index=0;
}
