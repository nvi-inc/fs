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
/* mk5 last_check SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

void last_check(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task */
int ip[5];                           /* ipc parameters */
{
      int ierr, i;
      char output[MAX_OUT];

      if (command->equal == '=' ) {
	ierr=-301;
	goto error;
      }

      for (i=0;i<5;i++) ip[i]=0;
      if(strlen(shm_addr->last_check.string)!=0) {
	strcpy(output,command->name);
	strcat(output,"/");
	append_safe(output,shm_addr->last_check.string,sizeof(output));

	cls_snd(&ip[0],output,strlen(output),0,0);
	ip[1]=1;
      }

      if(shm_addr->last_check.ip2!=0)
	logit(NULL,shm_addr->last_check.ip2,shm_addr->last_check.who);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5k",2);
      return;
}
