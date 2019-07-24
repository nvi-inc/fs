#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define MAX_IN 82
#define NSEMNAME "fs   "

static long ipr[5] = { 0, 0, 0, 0, 0};

main(argc,argv)
int argc;
char *argv[ ];
{
    char input[ MAX_IN];
    int length;
    void setup_ids();
    int kextin;

    setup_ids();

    kextin = (strcmp("oprin",argv[0]+strlen(argv[0])-5)!=0);

    if (kextin) {
      if (nsem_test(NSEMNAME) != 1) {
         printf("extin:Field System not running\n");
         exit(0);
      }
      fprintf( stdout, "extin>");
    } else {
      sig_ignore();
      fprintf( stdout, ">");
    }
 
    while ( TRUE ) {
       if(NULL != fgets(input, MAX_IN, stdin)) {
         if (kextin && nsem_test(NSEMNAME) != 1) {
            printf("extin:Field System not running\n");
            exit(0);
         }
         length = strlen( input)-1;
         cls_snd( &(shm_addr->iclopr), input, length, 0, 0);
         skd_run("boss ",'n',ipr);

         if (kextin)
            fprintf( stdout, "extin>");
         else
            fprintf( stdout, ">");
       } else if (kextin)
         exit(0);
    }
}
