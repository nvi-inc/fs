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
/* vlba rec display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void rec_dis(command,ip,indx)
struct cmd_ds *command;
int ip[5];
int indx;
{
      int i, ierr, kcom;
      int totlen;
      struct res_buf buffer;
      struct res_rec response;
      void get_res(); void opn_res();
      char output[MAX_OUT];
      char feet[6];

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && (command->equal == '=')) {
         logmsg(output,command,ip);
         return;
      }
      else if (kcom) {
        ierr = -201;
        goto error;
      }
      else {

   /* format output buffer */

        strcpy(output,command->name);
        strcat(output,"/");
        opn_res(&buffer,ip);

        get_res(&response, &buffer);  /* 30 */
        sprintf(output+strlen(output),"%u",response.data);
        strcat(output,",");

        feet[0]='\0';
        int2str(feet,response.data,-5,1); 
        memcpy(shm_addr->LFEET_FS[indx],feet,5);

        if (!((shm_addr->equip.drive[indx] == VLBA &&
	      shm_addr->equip.drive_type[indx] == VLBA2)||
	      (shm_addr->equip.drive[indx] == VLBA4 &&
	      shm_addr->equip.drive_type[indx] == VLBA42))) {
          get_res(&response, &buffer);  /* 31 */
          totlen = response.data;
          sprintf(output+strlen(output),"%u",response.data);
	}
        strcat(output,",");

        if (!((shm_addr->equip.drive[indx] == VLBA &&
	      shm_addr->equip.drive_type[indx] == VLBA2)||
	     (shm_addr->equip.drive[indx] == VLBA4 &&
	      shm_addr->equip.drive_type[indx] == VLBA42))) {
          get_res(&response, &buffer);  /* 32 */
          sprintf(output+strlen(output),"%u",response.data);
        }
        strcat(output,",");

        if (!((shm_addr->equip.drive[indx] == VLBA &&
	      shm_addr->equip.drive_type[indx] == VLBA2)||
	      (shm_addr->equip.drive[indx] == VLBA4 &&
	      shm_addr->equip.drive_type[indx] == VLBA42))) {
          totlen+=response.data;
          sprintf(output+strlen(output),"%d",totlen);
	}
        strcat(output,",");

        get_res(&response, &buffer);  /* 71 */
        sprintf(output+strlen(output),"%1.1x",response.data);
        strcat(output,",");

        if(response.state == -1) {
          clr_res(&buffer);
          ierr=-401;
          goto error;
        }
        clr_res(&buffer);
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
      memcpy(ip+3,"rc",2);
      return;
}
