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
/* mk5 scan_check SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void scan_check(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      int iOverRide;

      void skd_run(), skd_par();      /* program scheduling utilities */

      if(shm_addr->equip.drive[shm_addr->select] != MK5 ) {
	ierr=-402;
	goto error;
      }

      shm_addr->last_check.string[0]=0;
      append_safe(shm_addr->last_check.string,command->name,
		  sizeof(shm_addr->last_check.string));
      shm_addr->last_check.ip2=0;

      iOverRide = 0;
      if (command->equal == '=' && !strcasecmp(command->argv[0],"force")) {
	iOverRide = 1;
      } else if (command->equal == '=') {
 	ierr=-301;
	goto error;
      }

      if(0!=memcmp(shm_addr->LSKD,"none ",5) &&
	 !shm_addr->scan_name.name_old[0] && !iOverRide) {
	ierr=302;
	goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      out_recs=0;
      out_class=0;

      strcpy(outbuf,"scan_check?\n");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;
      
mk5cn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	shm_addr->last_check.ip2=ip[2];
	memcpy(shm_addr->last_check.who,ip+3,2);
	shm_addr->last_check.who[2]=0;
	return;
      }
      scan_check_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5k",2);

      shm_addr->last_check.ip2=ip[2];
      memcpy(shm_addr->last_check.who,ip+3,2);
      shm_addr->last_check.who[2]=0;
      return;
}
