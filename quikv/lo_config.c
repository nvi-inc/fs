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
/* if_config snap command */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void lo_config(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ierr;
      int verr;
      char *antcn_mode_st;
      int antcn_mode;

      ip[0]=ip[1]=ip[2]=ierr=0;

      antcn_mode_st=getenv("FS_LO_CONFIG_ANTCN_MODE");
      if (antcn_mode_st && *antcn_mode_st) {
          antcn_mode = atoi(antcn_mode_st);
          if(antcn_mode > 99) {
              ip[0]=antcn_mode;
              antcn(ip);
              if(ip[2]<0)
                  return;
          } else
              ierr=-502;
              goto error;
      }
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q*",2); /* shared with lo.c */
      return;
}
