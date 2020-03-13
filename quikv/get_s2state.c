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
/* retreive s2 state */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"

#include "../rclco/rcl/rcl_def.h"

int get_s2state(int ip[], char *lwho)
{
  struct rclcn_req_buf req_buf;        /* rclcn request buffer */
  struct rclcn_res_buf res_buf;
  char device[]= "r1";
  int rstate;

  void ini_rclcn_req(), end_rclcn_req(); /*rclcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */
  int i, ierr=0;

  ini_rclcn_req(&req_buf);

  add_rclcn_state_read(&req_buf,device);

  end_rclcn_req(ip,&req_buf);

  skd_run("rclcn",'w',ip);

  skd_par(ip);

  if (ip[2]<0) {
    ip[1]=0;
    cls_clr(ip[0]);
    return 0;
  }

  opn_rclcn_res(&res_buf,ip);

  ierr=get_rclcn_state_read(&res_buf,&rstate);

error:
  if(ierr!=0) {
    ip[2]=ierr;
    memcpy(ip+3,lwho,2);
  }

  clr_rclcn_res(&res_buf);
  return rstate;
  
}


