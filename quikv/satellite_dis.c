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
/* satellite display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void satellite_dis(command,ip)
struct cmd_ds *command;
int ip[5];
{
      struct satellite_cmd lclc;
      int kcom, i, ierr, count, start;
      char output[MAX_OUT];

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         return;
      } else if (kcom){
	memcpy(&lclc,&shm_addr->satellite,sizeof(lclc));
      } else {
	memcpy(&lclc,&shm_addr->satellite,sizeof(lclc));
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=strlen(output);

      for (i=0;i<5;i++) ip[i]=0;

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        satellite_enc(output,&count,&lclc);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);

      sprintf(output+start,"/tle0,%.24s",lclc.tle0);
      cls_snd(&ip[0],output,strlen(output),0,0);
      sprintf(output+start,"/tle1,%.69s",lclc.tle1);
      cls_snd(&ip[0],output,strlen(output),0,0);
      sprintf(output+start,"/tle2,%.69s",lclc.tle2);
      cls_snd(&ip[0],output,strlen(output),0,0);

      ip[1]=4;

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q2",2);
      return;
}
