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
/* K4 OLDTAPE SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 257

void k4oldtp(command,itask,ip)
struct cmd_ds *command;           /* parsed command structure */
int itask;
int ip[5];                       /* ipc parameters */
{
      int i;
      char *tpnum, tape[10];
      char cmd[MAX_BUF], output[MAX_BUF];
      char lampcmd[MAX_BUF];
      int ierr, max;
      void skd_run(), skd_par();  /* program scheduling utilities */

      if(shm_addr->equip.drive[0]==K4 &&
	  (shm_addr->equip.drive_type[0]==K41 ||
	   shm_addr->equip.drive_type[0]==K42)){
	ip[0]=ip[1]=0;
	return;
      } else if(command->equal != '=' ||command->argv[0]==NULL) {
        ierr=-301;
        goto error1;
      }

      i=0;
      tpnum=command->argv[0];

      if(tpnum!=NULL)
	while(*tpnum != '\0'){
	  tape[i] = *tpnum;
	  i++; tpnum++;
	}
      tape[i] = '\0';

/* This is the 'MOVE' command */

      strcpy(cmd,"move=dr1,");
      if(tape[1] == '\0') strcat(cmd,"0");
      strcat(cmd,tape);
      strcat(cmd,"c");

      for (i=0;i<5;i++) ip[i]=0;

      ib_req2(ip,"t1",cmd);

      skd_run("ibcon",'w',ip);
      skd_par(ip);
      if(ip[2]<0) goto error2;

/* This is the 'BINLAMP' command */
/* Kurihara added following 12 lines */

      strcpy(lampcmd,"binlamp=");
      if(tape[1] == '\0') strcat(lampcmd,"0");
      strcat(lampcmd,tape);
      strcat(lampcmd,"c,1");

      for (i=0;i<5;i++) ip[i]=0;

      ib_req2(ip,"t1",lampcmd);

      skd_run("ibcon",'w',ip);
      skd_par(ip);
      if(ip[2]<0) goto error2;
      return;

error1:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ko",2);
      return;

error2:
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
      return;
}
