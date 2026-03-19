/*
 * Copyright (c) 2026 NVI, Inc.
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
/* rxg_reload snap command */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void rxg_reload(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
  int ierr, i, start;
  char output[513];

  struct rxgain_ds rxgain[MAX_RXGAIN];
  struct rxgain_files_ds rxgain_files[MAX_RXGAIN];
  struct lo_cmd lcl;

  for (i=0;i<5;i++) ip[i]=0;

  if (command->equal == '=') {
     ierr=-999;
     goto error;
  }

  for (i=0;i<MAX_RXGAIN;i++)
    rxgain[i].type=0;

  get_rxgain_files(&ierr,&rxgain,&rxgain_files);

  if(0==ierr) {
    memcpy(shm_addr->rxgain,rxgain,sizeof(shm_addr->rxgain));
    memcpy(shm_addr->rxgain_files,rxgain_files,sizeof(shm_addr->rxgain_files));
    memcpy(&lcl,&shm_addr->lo,sizeof(lcl));
    strcpy(output,command->name);
    strcat(output,"/");
    start=strlen(output);

    for(i=0;i<MAX_LO;i++)
      if(lcl.lo[i]>=0.0) {
	lo_rxg_enc(output,i,&lcl);
	cls_snd(&ip[0],output,strlen(output),0,0);
	ip[1]++;
	output[start]='\0';
	log_rxgfile(i);
      }
  } else {
    logit(NULL,ierr,"rg");
    ierr=-19;
  }
  return;

error:
  ip[2]=ierr;
  memcpy(ip+3,"rg",2);
  return;
}
