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
/* S2 recorder rec display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "../rclco/rcl/rcl_def.h"

#define MAX_OUT 256

void s2rec_dis(command,ip)
struct cmd_ds *command;
int ip[5];
{
      struct rec_mode_cmd lclc;
      int kcom, i, ierr, count, start;
      struct rclcn_res_buf buffer;
      char output[MAX_OUT];

      ierr=0;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logrclmsg(output,command,ip);
         return;
      } else if (kcom){
	ierr = -101;
	goto error;
      } else {
	int code;
	union pos_union position;
	char version[RCL_MAXSTRLEN_VERSION];
	int year, day, hour, min, sec;
	ibool validated;
	int centisec[6];

	/* format output buffer */

	strcpy(output,command->name);
	strcat(output,"/");

	opn_rclcn_res(&buffer,ip);

	ierr=get_rclcn_position_read(&buffer, &code, &position);
	if(ierr!=0)
	  goto error;

	if(code!=0) {
	  ierr=-302;
	  goto error;
	}
	if (position.overall.position == RCL_POS_UNKNOWN)
	  strcat(output,"<unk>");
	else
	  sprintf(output+strlen(output),"%i",position.overall.position);
	if (position.overall.posvar == RCL_POS_UNKNOWN)
	  strcat(output,",<unk>");
	else
	  sprintf(output+strlen(output),",%i",position.overall.posvar);

	ierr=get_rclcn_version(&buffer,version);
	if(ierr!=0)
	  goto error;

	ierr=get_rclcn_time_read(&buffer,&year,&day,&hour,&min,&sec,
				 &validated, centisec);
	if(ierr!=0)
	  goto error;

	sprintf(output+strlen(output),",%04d/%03d.%02d:%02d:%02d",
		year,day,hour,min,sec);
    
	if(validated)
	  strcat(output,",valid");
	else
	  strcat(output,",not-valid");

	/*
	sprintf(output+strlen(output),",%ld,%ld,%ld,%ld,%ld,%ld",
		centisec[0],centisec[2],centisec[4],
		centisec[1],centisec[3],centisec[5]);
	*/

	sprintf(output+strlen(output),",%s",version);

	clr_rclcn_res(&buffer);
      }

      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]++;

      return;

error:
      clr_rclcn_res(&buffer);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rv",2);
      return;
}
