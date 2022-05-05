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
/* S2 recorder user_info snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"r1"};           /* device menemonics */

void s2tape(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, i, count;
      int verr;
      char *ptr;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      int position[8];

      int s2tape_dec();                 /* parsing utilities */
      char *arg_next();

      void s2tape_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_position_read();
      void add_rclcn_position_set();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_rclcn_req(&buffer);

      if (command->equal != '=') {            /* read module */
	add_rclcn_position_read(&buffer,device,1);
	goto rclcn;
      } else if (command->argv[0]==NULL)   /* simple equals */
	goto parse;
      else if (command->argv[1]==NULL)     /* special cases */
        if (strcmp(command->argv[0],"reset")==0) {
	  add_rclcn_position_set(&buffer,device,2, (int) 0);
	  goto rclcn;
	}

      
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=s2tape_dec(position,&count, ptr);
        if(ierr !=0 )
	  goto error;
      }

/* format buffers for mcbcn */
      
      if (ilast==1)
	add_rclcn_position_set(&buffer,device,2,position[0]);
      else if(ilast==8)
	add_rclcn_position_set_ind(&buffer,device,2,position);
      else {
	ierr=-301;
	goto error;
      }

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      s2tape_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rt",2);
      return;
}
