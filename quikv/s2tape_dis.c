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

void s2tape_dis(command,ip)
struct cmd_ds *command;
int ip[5];
{
      int kcom, i, ierr, count, start;
      struct res_buf buffer;
      struct res_rec response;
      char output[MAX_OUT];
      int code;
      union pos_union position;

      if (command->equal == '=') {
         logrclmsg(output,command,ip);
         return;
      } else {
	opn_rclcn_res(&buffer,ip);
	ierr=get_rclcn_position_read(&buffer, &code, &position);
	if(ierr!=0)
	  goto error;
      }

      clr_rclcn_res(&buffer);


   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=strlen(output);

      for (i=0;i<5;i++)
	ip[i]=0;

      for (i=0;i<position.individual.num_entries;i++)
	if (position.individual.position[i] == RCL_POS_UNKNOWN)
	  strcat(output,"<unk>,");
	else if (position.individual.position[i] == RCL_POS_UNSEL)
	  strcat(output,"<uns>,");
	else
	  sprintf(output+strlen(output),"%i,",
		  position.individual.position[i]);

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]++;

      return;

error:
      clr_rclcn_res(&buffer);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rt",2);
      return;
}
