/* S2 recorder tape display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "../rclco/rcl/rcl.h"

#define MAX_OUT 256

void s2rec_dis(command,ip)
struct cmd_ds *command;
long ip[5];
{
      char output[MAX_OUT];

      logrclmsg(output,command,ip);
      return;
}
