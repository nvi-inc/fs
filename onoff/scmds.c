#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

void scmds(mess)
     char *mess;
{
  long ip[5];

  cls_snd( &(shm_addr->iclopr), mess, strlen(mess) , 0, 0);
  skd_run("boss ",'n',ip);

  go_take("onoff",0);

  return;
}
