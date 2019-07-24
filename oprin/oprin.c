#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define MAX_IN 82

static long ipr[5] = { 0, 0, 0, 0, 0};

main()
{
    char input[ MAX_IN];
    int length;
    void setup_ids();

    setup_ids();
    sig_ignore();

    fprintf( stdout, ">");
    while ( TRUE ) {
       if(NULL != fgets(input, MAX_IN, stdin)) {
         length = strlen( input)-1;
         cls_snd( &(shm_addr->iclopr), input, length, 0, 0);
         skd_run("boss ",'n',ipr);
         fprintf( stdout, ">");
       }
    }
}
