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
/* S2 rcl SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void rcl(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ierr, icmd;
      struct rclcn_req_buf buffer;           /* rclcn request buffer */
      char *arg_next();
                                            /*rclcn request utilities */
      void ini_rclcn_req(), add_rclcn_req(), end_rclcn_req();
      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_rclcn_req(&buffer);

      if (command->equal != '=' ||
          command->argv[0]==NULL||
	  command->argv[1]==NULL) {
         ierr=-201;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ierr=rcl_dec(command,&buffer,&icmd);
      if (ierr!=0)
	goto error;

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }
      rcl_dis(command,icmd,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rm",2);
      return;
}
