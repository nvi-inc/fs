#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

extern void skd_run(char name[5], char w, long ip[5]);

static long ipr[5] = { 0, 0, 0, 0, 0};

int
main(int argc, char **argv)
{
  int length;

  setup_ids();

  if (nsem_test("fs   ") != 1 || argc < 2) {
    exit(-1);
  }
  length = strlen(argv[1]);
  
  /* Execute this SNAP command via "boss". */
  cls_snd( &(shm_addr->iclopr), argv[1], length, 0, 0);
  skd_run("boss ",'n',ipr);

  return (0);  /* ok termination */

}
