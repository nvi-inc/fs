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
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void logrclmsg(output,command,ip)
char *output;
struct cmd_ds *command;
int ip[5];
{
   struct res_buf buffer;
   struct res_rec response;
   void opn_res(), get_res(), clr_res(), cls_snd();
   int first, i, ierr;

   opn_rclcn_res(&buffer,ip);
   for (i=0;i<5;i++) ip[i]=0;

   strcpy(output,command->name);
   strcat(output,"/");
   first=TRUE;

   ierr=get_rclcn_res(&buffer);
   while(ierr == 0) {    /* log command/ if no responses */
     while(ierr == 0 && strlen(output)+5<128) {
       if(first){
         strcat(output,"ack");
         first=FALSE;
       } else
         strcat(output,",ack");
       ierr=get_rclcn_res(&buffer);
     }
     if(ierr == 0){
       cls_snd(ip,output,strlen(output),0,0);
       ip[1]++;
       strcpy(output,command->name);
       strcat(output,"/");
       first=TRUE;
     }
   }
   cls_snd(ip,output,strlen(output),0,0);
   ip[1]++;

   clr_rclcn_res(&buffer);
   return;

}
