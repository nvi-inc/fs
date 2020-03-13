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
/* ds SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"

/* function prototypes */
void cls_snd();				/* class buffer utilities */
int dscon_rcv();			/* DSCON interface utilities */
void ds_mon();

void ds_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      int ierr, count, i;
      struct ds_mon lclm;
      char output[80];

      /* retrieve the response data */

      if ((ierr=dscon_rcv(&lclm,ip))) goto error;

      /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while ( count>=0 ) {
        if (count>0) strcat(output,",");
        count++;
        ds_mon(output,&count,&lclm);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ds",2);
      return;
}
