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
/* vlba tape display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

void tape_dis(command,itask,ip,indx)
struct cmd_ds *command;
int itask,indx;
int ip[5];
{
      struct tape_cmd lclc;
      struct tape_mon lclm;
      int ind,kcom,i,ich, ierr, count;
      struct res_buf buffer;
      struct res_rec response;
      void get_res();
      void mcb6tape(), mc30tape(), mc33tape(), mc57tape();
      void mc72tape(), mc73tape(), mc74tape();

      char output[MAX_OUT];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmsg(output,command,ip);
         return;
      }
      else if (kcom) {
         memcpy(&lclc,&shm_addr->lowtp[indx],sizeof(lclc));
      }
      else {
         opn_res(&buffer,ip);
         get_res(&response, &buffer); mcb6tape(&lclc, response.data);
         get_res(&response, &buffer); mc30tape(&lclm, response.data);
         get_res(&response, &buffer); mc33tape(&lclm, response.data);
	 if(!((shm_addr->equip.drive[indx] == VLBA &&
	      shm_addr->equip.drive_type[indx] == VLBA2)||
	      (shm_addr->equip.drive[indx] == VLBA4 &&
	       shm_addr->equip.drive_type[indx] == VLBA42)))
	   get_res(&response, &buffer); mc57tape(&lclm, response.data);
         get_res(&response, &buffer); mc72tape(&lclm, response.data);
         get_res(&response, &buffer); mc73tape(&lclm, response.data);
         get_res(&response, &buffer); mc74tape(&lclm, response.data);
         if(response.state == -1) {
            clr_res(&buffer);
            ierr=-401;
            goto error;
         }
         clr_res(&buffer);
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        tape_enc(output,&count,&lclc);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          tape_mon(output,&count,&lclm,indx);
        }
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
      memcpy(ip+3,"vt",2);
      return;
}
