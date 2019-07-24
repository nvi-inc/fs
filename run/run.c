#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

static long ipr[5] = { 0, 0, 0, 0, 0};
extern struct fscom *shm_addr;

main(argc, argv)
int argc;
char **argv;
{
    void setup_ids(), skd_run();
    char mess[20];
    int ivalue;

    setup_ids();
    skd_run(argv[1],*argv[2],ipr);
    sprintf(mess,"%-5.5s finished",argv[1]);
    memcpy(&ivalue,"to",2);
    if (*argv[2] == 'w') cls_snd(&(shm_addr->iclbox),mess,14,0,ivalue);

    exit( 0);
}
