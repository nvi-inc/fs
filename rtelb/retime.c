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

    int it[6];
    long secs;
    setup_ids();    /* attach to the shared memory */

    fs = shm_addr;
    prcomm();
    rte_time(it,it+5);
    prtime(it);

}
prcomm()
{
    int index;
    index=fs->time.index;
    printf(" index %d\n", index);

    printf("current:\n offset %12d rate*1e6 %20lf epoch %12d hs %3d\n",
            fs->time.offset[index],
            fs->time.rate[index]*1e6,
            fs->time.epoch[index],
            fs->time.epochhs[index]);
    index=1-index;
    printf("other:\n offset %12d rate*1e6 %20lf epoch %12d hs %3d\n",
            fs->time.offset[index],
            fs->time.rate[index]*1e6,
            fs->time.epoch[index],
            fs->time.epochhs[index]);
    printf("\n");
}
prtime(it)
int it[6];
{
    int i;
    long secs;

    for (i=0;i<5;i++)
        printf("%5d",it[i]);
    rte2secs(it,&secs);
    printf("  secs %12ld\n",secs);
}
