#include <stdio.h>
#include <signal.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

void incom_ini( iclbox, iclopr)
long *iclbox,*iclopr;
{

   *iclbox=shm_addr->iclbox;
   *iclopr=shm_addr->iclopr;

}
