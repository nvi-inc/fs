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
/* k4 vc display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void k4vc_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
  struct k4vc_cmd lclc;
  struct k4vc_mon lclm;
  int kcom, i, ierr, count, start;
  char output[MAX_OUT];

  kcom= command->argv[0] != NULL &&
    *command->argv[0] == '?' && command->argv[1] == NULL;

  if ((!kcom) && command->equal == '=') {
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=0;
    }
    ip[1]=0;
    return;
  } else if (kcom){
    memcpy(&lclc,&shm_addr->k4vc,sizeof(lclc));
  } else {
    k4vc_res_q(&lclc,&lclm,ip,itask);
    if(ip[1]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    if(ip[2]!=0) {
      ierr=ip[2];
      goto error;
    }
  }

   /* format output buffer */

  strcpy(output,command->name);
  strcat(output,"/");
  start=strlen(output);

  for (i=0;i<5;i++)
    ip[i]=0;

  count=0;
  while( count>= 0) {
    count++; 
    k4vc_enc(output,&count,&lclc,itask);
    if(count > 0) {
      if(!kcom) {
	strcat(output,",");
	k4vc_mon(output,&count,&lclm,itask);
      }
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]++;
      output[start]='\0';
    }
  }

  return;
  
 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"kv",2);
  return;
}

