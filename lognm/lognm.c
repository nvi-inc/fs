/* lognm.c print log name to standard output */

#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

main(argc, argv)
int argc;
char **argv;
{
    void setup_ids();
    char log[9];
    int i;

    setup_ids();

    if ( 1 != nsem_take("fs   ",1)) {
         exit( -1);
    }

    memcpy(log, shm_addr->LLOG, 8);
    log[8]=0;

    for(i=7;0<=i;i--) {
      if(log[i]!=' ')
	goto print;
      log[i]=0;
    }

  print:
    printf("%s\n",log);

    exit( 0);
}
