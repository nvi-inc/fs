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
/* chekr s2 rec routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl_def.h"

void s2recchk_(icherr,lwho)
int icherr[];
char *lwho;
{
  int ip[5];            /* ipc parameters */
  struct rclcn_req_buf req_buf;        /* rclcn request buffer */
  struct rclcn_res_buf res_buf;
  struct s2rec_check s2rec;
  char device[]= "r1";

  void ini_rclcn_req(), end_rclcn_req(); /*rclcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */
  int i, ierr=0;

  ini_rclcn_req(&req_buf);
  add_rclcn_delaym_read(&req_buf,device);
  end_rclcn_req(ip,&req_buf);

  nsem_take("fsctl",0);

  skd_run("rclcn",'w',ip);

  nsem_put("fsctl");
  skd_par(ip);

  if (ip[2]<0) {
    cls_clr(ip[0]);
    logita(NULL,ip[2],ip+3,ip+4);
    logita(NULL,-500,lwho,"rc");
  } else {

    int nanosec;
    
    opn_rclcn_res(&res_buf,ip);
    ierr=get_rclcn_delaym_read(&res_buf,&nanosec);
    if(ierr!=0) {
      logita(NULL,ierr-20,lwho,"rc");
      logita(NULL,-500,lwho,"rc");
    } else {
      char outbuf[80];
      if(nanosec!=0) {
	sprintf(outbuf,"measured delay not ZERO, actual value %d nanseconds",
		nanosec);
	logite(outbuf,-499,"ch");
      }
    }

  }

  clr_rclcn_res(&res_buf);

  memcpy(&s2rec,&shm_addr->check.s2rec,sizeof(struct s2rec_check));
  
  ierr=0;

  ini_rclcn_req(&req_buf);

  for (i=0;i<4;i++) {
    int fieldnum=i+1;
    ibool label=TRUE;

    if(s2rec.user_info.label[i])
      add_rclcn_user_info_read(&req_buf,device,fieldnum,label);
  }
  for (i=0;i<4;i++) {
    int fieldnum=i+1;
    ibool label=FALSE;

    if(s2rec.user_info.field[i])
      add_rclcn_user_info_read(&req_buf,device,fieldnum,label);
  }

  if(s2rec.speed)
    add_rclcn_speed_read(&req_buf,device);

  if(s2rec.mode)
    add_rclcn_mode_read(&req_buf,device);

  if(s2rec.group)
    add_rclcn_group_read(&req_buf,device);

  if(s2rec.roll)
    add_rclcn_barrelroll_read(&req_buf,device);

  if(s2rec.dv)
    add_rclcn_user_dv_read(&req_buf,device);

  if(s2rec.tapeid)
    add_rclcn_tapeid_read(&req_buf,device);

  if(s2rec.tapetype)
    add_rclcn_tapetype_read(&req_buf,device);

  end_rclcn_req(ip,&req_buf);

  nsem_take("fsctl",0);

  skd_run("rclcn",'w',ip);

  nsem_put("fsctl");
  skd_par(ip);

  if (ip[2]<0) {
    cls_clr(ip[0]);
    logita(NULL,ip[2],ip+3,ip+4);
    return;
  }
  opn_rclcn_res(&res_buf,ip);
  for (i=0;i<4;i++) {
    char user_info[RCL_MAXSTRLEN_USER_INFO];

    if(s2rec.user_info.label[i]) {
      ierr=get_rclcn_user_info_read(&res_buf,user_info);
      if(ierr!=0)
	goto error;
      icherr[i]=strcmp(user_info,shm_addr->user_info.labels[i])!=0;
    }
  }
  for (i=1;i<5;i++) {
    char user_info[RCL_MAXSTRLEN_USER_INFO];

    if(s2rec.user_info.field[i-1]) {
      ierr=get_rclcn_user_info_read(&res_buf,user_info);
      if(ierr!=0)
	goto error;
      switch (i) {
      case 1:
	icherr[3+i]=strcmp(user_info,shm_addr->user_info.field1)!=0;
	break;
      case 2:
	icherr[3+i]=strcmp(user_info,shm_addr->user_info.field2)!=0;
	break;
      case 3:
	icherr[3+i]=strcmp(user_info,shm_addr->user_info.field3)!=0;
	break;
      case 4:
	icherr[3+i]=strcmp(user_info,shm_addr->user_info.field4)!=0;
	break;
      }
    }
  }

  if(s2rec.speed)  {
    int speed;

    ierr=get_rclcn_speed_read(&res_buf,&speed);
    if(ierr!=0)
      goto error;

    icherr[8]=speed!=shm_addr->s2st.speed;
  }

  if(s2rec.state) {
    int inuse=shm_addr->actual.s2rec_inuse;
    icherr[9]=shm_addr->actual.s2rec[inuse].rstate!=shm_addr->s2_rec_state;
  }

  if(s2rec.mode)  {
    char mode[RCL_MAXSTRLEN_MODE];

    ierr=get_rclcn_mode_read(&res_buf,mode);
    if(ierr!=0)
      goto error;

    icherr[10]=strcmp(mode,shm_addr->rec_mode.mode)!=0;
  }

  if(s2rec.group)  {
    int group, num_groups;

    ierr=get_rclcn_group_read(&res_buf,&group,&num_groups);
    if(ierr!=0)
      goto error;
    
    icherr[11]=group!=shm_addr->rec_mode.group;
  }

  if(s2rec.roll)  {
    ibool barrelroll;
    int roll;

    ierr=get_rclcn_barrelroll_read(&res_buf,&barrelroll);
    if(ierr!=0)
      goto error;
    
    if(barrelroll)
      roll=1;
    else
      roll=0;

    icherr[17]=roll!=shm_addr->rec_mode.roll;
  }

  if(s2rec.dv)  {
    ibool user_dv, pb_enable;

    ierr=get_rclcn_user_dv_read(&res_buf,&user_dv,&pb_enable);
    if(ierr!=0)
      goto error;
    
    icherr[12]=user_dv && !shm_addr->data_valid[0].user_dv
      || !user_dv && shm_addr->data_valid[0].user_dv;

    icherr[13]=pb_enable && !shm_addr->data_valid[0].pb_enable
      || !pb_enable && shm_addr->data_valid[0].pb_enable;

  }
  if(s2rec.tapeid) {
    char tapeid[RCL_MAXSTRLEN_TAPEID];

    ierr=get_rclcn_tapeid_read(&res_buf,tapeid);
    if(ierr!=0)
      goto error;

    icherr[14]=strcmp(tapeid,shm_addr->s2label.tapeid)!=0;
  }

  if(s2rec.tapetype)  {
    char tapetype[RCL_MAXSTRLEN_TAPETYPE];
    
    ierr=get_rclcn_tapetype_read(&res_buf,tapetype);
    if(ierr!=0)
      goto error;

    icherr[15]=strcmp(tapetype,shm_addr->s2label.tapetype)!=0;
    
  }


error:
  if(ierr!=0)
    logita(NULL,ierr-20,lwho,"rc");

  clr_rclcn_res(&res_buf);
  return;
  
}
