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
/* K4 recpatch function display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void k4recpatch_dis(command,lclc,ip)
struct cmd_ds *command;
struct k4recpatch_cmd *lclc;
int ip[5];
{
      int i, count, start_len;
      char output[MAX_OUT];

      for (i=0;i<5;i++)
	ip[i]=0;

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start_len=strlen(output);

      count=0;
      while( count>= 0) {
        if (start_len != strlen(output))
	  strcat(output,",");
        count++;
        k4recpatch_enc(output,&count,lclc);
        if(count < 0  && output[strlen(output)-1] == ',')
          output[strlen(output)-1]='\0';
	if( (count > 0 && strlen(output) > 62 )||
            (count < 0 && strlen(output) > start_len) ) {
	  cls_snd(&ip[0],output,strlen(output),0,0);
	  ip[1]++;
	  output[start_len]='\0';
	}
      }

      return;

}
