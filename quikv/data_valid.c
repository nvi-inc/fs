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
/* S2 recorder data_valid snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"r1"};           /* device menemonics */

void data_valid(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count, indx;
      int verr;
      char *ptr;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      struct data_valid_cmd lcl;

      int data_valid_dec();                 /* parsing utilities */
      char *arg_next();
      int kS2drive;

      void data_valid_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_user_dv_set();
      void add_rclcn_user_dv_read();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */
 
      indx=itask-1;

      kS2drive=indx >= 0 && shm_addr->equip.drive[indx] == S2;

      if(indx < 0)
	indx=0;

      if(kS2drive)
	ini_rclcn_req(&buffer);

      if (command->equal != '=') {           /* read module */
	if(kS2drive) {
	  add_rclcn_user_dv_read(&buffer,device);
	  goto rclcn;
	} else {
	  data_valid_dis(command,ip,indx,kS2drive);
	  return;
	}
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          data_valid_dis(command,ip,indx,kS2drive);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=data_valid_dec(&lcl,&count, ptr, kS2drive);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      if(kS2drive) {
	ichold=shm_addr->check.s2rec.check;
	shm_addr->check.s2rec.check=0;
      }
      
      memcpy(&shm_addr->data_valid[indx],&lcl,sizeof(lcl));

      skd_run("pcald",'w',ip);
      skd_run("tpicd",'w',ip);

      if(!kS2drive) {
	ip[0]=ip[1]=ip[2]=0;
	return;
      }

/* format buffers for rclcn */

      add_rclcn_user_dv_set(&buffer,device,lcl.user_dv,lcl.pb_enable);

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	shm_addr->check.s2rec.dv=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.s2rec.check=ichold;
      }
      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      data_valid_dis(command,ip,indx,kS2drive);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rd",2);
      return;
}
