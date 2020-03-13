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
/* k4 recorder rec snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void k4rec(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      char *ptr;

      char *arg_next();

      void k4rec_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ip[0]=ip[1]=0;

      if (command->equal != '=') {            /* read module */
	k4rec_req_q(ip);
	goto k4con;
      } else if (command->argv[0]==NULL) {  /* simple equals */
	ierr=-101;
        goto error;
      } else if(0==strcmp(command->argv[0],"eject")||
		0==strcmp(command->argv[0],"unload")
		) {
	k4rec_req_eject(ip);
      } else if(0==strcmp(command->argv[0],"init")||
		0==strcmp(command->argv[0],"ini")
		) {
	k4rec_req_ini(ip);
      } else if(0==strcmp(command->argv[0],"synch")) {
	k4rec_req_xsy(ip);
      } else if(0==strcmp(command->argv[0],"drum_on")) {
	k4rec_req_drum_on(ip);
      } else if(0==strcmp(command->argv[0],"drum_off")) {
	k4rec_req_drum_off(ip);
      } else if(0==strcmp(command->argv[0],"synch_on")) {
	k4rec_req_synch_on(ip);
      } else if(0==strcmp(command->argv[0],"synch_off")) {
	k4rec_req_synch_off(ip);
      } else {
	char *ptr=command->argv[0];
	int i,iend;
	if(ptr==NULL) {
	  ierr=-101;
	  goto error;
	} else if(strlen(ptr)>7) {
	  ierr=-201;
	  goto error;
	}
	iend=strlen(ptr);
	for(i=0;i<iend;i++) 
	  if(NULL==index("0123456789",ptr[i])) {
	    ierr=-201;
	    goto error;
	  }
	k4rec_req_prl(ip,ptr);
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.k4rec.check;
      shm_addr->check.k4rec.check=0;

k4con:
      skd_run("ibcon",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	shm_addr->check.k4rec.state=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.k4rec.check=ichold;
      }

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      k4rec_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"kr",2);
      return;
}
