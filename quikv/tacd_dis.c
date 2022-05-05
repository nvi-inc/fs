/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* Take a look at the TAC and logit.
*/

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/fscom.h"
#include "../include/pmodel.h"

extern struct fscom *fs;

#define MAX_OUT 256

void
tacd_dis(command,itask,ip)
struct cmd_ds *command;
int ip[5];
{
  char  output[MAX_OUT];
  int i, ierr;

  strcpy(output,command->name);
  strcat(output,"/");


  if((shm_addr->tacd.day == 0 ||
     shm_addr->tacd.day_frac == 0) &&
     (shm_addr->tacd.day_a == 0 ||
     shm_addr->tacd.day_frac_a == 0)) ierr=-9;

  if(!strcmp(command->argv[0],"status") ||
     !strcmp(command->argv[0],"?")) {
    if (ierr==-9) goto error;
    sprintf(output+strlen(output),
	    "status,%s,%d,%s,%s",
	    shm_addr->tacd.hostpc,
	    shm_addr->tacd.port,
	    shm_addr->tacd.file,
	    shm_addr->tacd.status);
  } else if(!strcmp(command->argv[0],"version")) {
    if (ierr==-9) goto error;
    sprintf(output+strlen(output),"version,%s",
	    shm_addr->tacd.tac_ver);
  } else if(!strcmp(command->argv[0],"stop")) {
    if (ierr==-9) goto error;
    sprintf(output+strlen(output),
	    "You have requested to stop checking the TAC.");
  } else if(!strcmp(command->argv[0],"single")) {
    if (ierr==-9) goto error;
    sprintf(output+strlen(output),
	    "Check the TAC every %d centisecs.",
	    shm_addr->tacd.check);
  } else if(!strcmp(command->argv[0],"time")) {
    if (ierr==-9) goto error;
    if(shm_addr->tacd.day_frac!=shm_addr->tacd.day_frac_old) {
      shm_addr->tacd.day_frac_old = shm_addr->tacd.day_frac;
      strcpy(shm_addr->tacd.oldnew,"time,NEW");
    } else {
      strcpy(shm_addr->tacd.oldnew,"time,OLD");
    }
    sprintf(output+strlen(output),
	    "%s,%d.%d,%f,%05.2f,%d,%f,%f",
	    shm_addr->tacd.oldnew,
	    shm_addr->tacd.day,
	    shm_addr->tacd.day_frac,
	    shm_addr->tacd.msec_counter,
	    shm_addr->tacd.usec_correction,
	    shm_addr->tacd.nsec_accuracy,
	    shm_addr->tacd.usec_bias,
	    shm_addr->tacd.cooked_correction);
  } else if(!strcmp(command->argv[0],"average")) {
    if (ierr==-9) goto error;
    if(shm_addr->tacd.day_frac_a!=shm_addr->tacd.day_frac_old_a) {
      shm_addr->tacd.day_frac_old_a = shm_addr->tacd.day_frac_a;
      strcpy(shm_addr->tacd.oldnew_a,"average,NEW");
    } else {
      strcpy(shm_addr->tacd.oldnew_a,"average,OLD");
    }
    sprintf(output+strlen(output),
	    "%s,%d.%d,%d,%f,%f,%f,%f",
	    shm_addr->tacd.oldnew_a,
	    shm_addr->tacd.day_a,
	    shm_addr->tacd.day_frac_a,
	    shm_addr->tacd.sec_average,
	    shm_addr->tacd.rms,
	    shm_addr->tacd.max,
	    shm_addr->tacd.min,
	    shm_addr->tacd.usec_average);
  } else if(!strcmp(command->argv[0],"cont")) {
    if (ierr==-9) goto error;
    sprintf(output+strlen(output),"retrive data every second.");
  }

  for (i=0;i<5;i++) ip[i]=0;
  cls_snd(&ip[0],output,strlen(output),0,0);
  ip[1]=1;

  return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ta",2);
      return;
}
