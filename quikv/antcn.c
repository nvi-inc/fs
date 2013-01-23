#include <stdlib.h>
#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int antcn(long ip[5])
{

  if(0==strncmp(shm_addr->idevant,"/dev/null ",10)) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=-400;
    memcpy(ip+3,"q2",2);
    return;
  }

  ip[2]=0;
  skd_run("antcn",'w',ip);

  if(ip[2] >= 0) {
    ip[2]=0;
    skd_run("flagr",'n',ip);
  }

}
