/* Take a look at the TAC and logit.
*/

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/fs_types.h"
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/params.h"
#include "../include/fscom.h"
#include "../include/pmodel.h"

extern struct fscom *fs;

#define MAX_OUT 256

void
tacd_dis(command,itask,ip)
struct cmd_ds *command;
long ip[5];
{
  char  output[MAX_OUT];
  int i;

  strcpy(output,command->name);
  strcat(output,"/");


  if(!strcmp(command->argv[0],"status") ||
     !strcmp(command->argv[0],"?")) {
    sprintf(output+strlen(output),
	    "status,%s,%d,%s,%s",
	    shm_addr->tacd.hostpc,
	    shm_addr->tacd.port,
	    shm_addr->tacd.file,
	    shm_addr->tacd.status);
  } else if(!strcmp(command->argv[0],"stop")) {
    sprintf(output+strlen(output),
	    "You have requested to stop checking the TAC.");
  } else if(!strcmp(command->argv[0],"single")) {
    sprintf(output+strlen(output),
	    "Check the TAC every %d centisecs.",
	    shm_addr->tacd.check);
  } else if(!strcmp(command->argv[0],"time")) {
    if(shm_addr->tacd.day_frac!=shm_addr->tacd.day_frac_old) {
      shm_addr->tacd.day_frac_old = shm_addr->tacd.day_frac;
      strcpy(shm_addr->tacd.oldnew,"time,NEW\0");
    } else {
      strcpy(shm_addr->tacd.oldnew,"time,OLD\0");
    }
    sprintf(output+strlen(output),
	    "%s,%lf,%lf,%d,%d,%lf,%lf",
	    shm_addr->tacd.oldnew,
	    shm_addr->tacd.day_frac,
	    shm_addr->tacd.msec_counter,
	    shm_addr->tacd.usec_correction,
	    shm_addr->tacd.nsec_accuracy,
	    shm_addr->tacd.usec_bias,
	    shm_addr->tacd.cooked_correction,
	    shm_addr->tacd.msec_counter);
  } else if(!strcmp(command->argv[0],"average")) {
    if(shm_addr->tacd.day_frac!=shm_addr->tacd.day_frac_old) {
      shm_addr->tacd.day_frac_old = shm_addr->tacd.day_frac;
      strcpy(shm_addr->tacd.oldnew,"average,NEW\0");
    } else {
      strcpy(shm_addr->tacd.oldnew,"average,OLD\0");
    }
    sprintf(output+strlen(output),
	    "%s,%lf,%d,%lf,%lf,%lf,%lf",
	    shm_addr->tacd.oldnew,
	    shm_addr->tacd.day_frac,
	    shm_addr->tacd.sec_average,
	    shm_addr->tacd.rms,
	    shm_addr->tacd.max,
	    shm_addr->tacd.min,
	    shm_addr->tacd.usec_average);
  } else if(!strcmp(command->argv[0],"cont")) {
    sprintf(output+strlen(output),"retrive data every second.");
  }

  for (i=0;i<5;i++) ip[i]=0;
  cls_snd(&ip[0],output,strlen(output),0,0);
  ip[1]=1;

  return;

error:
      ip[0]=0;
      ip[1]=0;
      memcpy(ip+3,"st",2);
      return;
}
