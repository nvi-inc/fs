#include <stdlib.h>
#include <sys/types.h>

#include "rcl.h"
#include "rcl_def.h"
#include "rcl_cmd.h"
#include "rcl_pkt.h"
#include "rcl_sys.h"

int main(int argc, char *argv[])
{
   int err;
   int addr;
   char errmsg[256];      /* error message from rcl_open() */

   if (argv[1]==NULL || argv[1][0]==NULL)  {
      fprintf(stderr,"Must supply a host name\n");
      fprintf(stderr,"Usage:  test hostname\n");
      exit(1);
   }

   RclDebug=1;

   printf("RCL_INIT: %d\n", rcl_init());

   err = rcl_open(argv[1], &addr, errmsg);
   printf("RCL_OPEN: %d (%s)\n", err, errmsg);
   if (err != RCL_ERR_NONE)
       exit(err);

   printf("RCL_PLAY: %d\n", rcl_play(addr));

   printf("RCL_SHUTDOWN: %d\n", rcl_shutdown());

   return(0);
}
