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
/* ds SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"

/* function prototypes */
char *arg_next();                      /* command parsing utilities */
void dscon_snd();                      /* DSCON interface utilities */
int run_dscon();
int ds_dec();                        /* ds SNAP command utilities */
void ds_dis();                       /* ds SNAP command display */

void ds(command,itask,ip)
struct cmd_ds *command;               /* parsed command structure */
int itask;                            /* sub-task - unused */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, count, i;
      struct ds_cmd lcl;            /* local Dataset request buffer */
      char *ptr;

      if ( command->equal != '=' || 
           command->argv[0]==NULL ||
           command->argv[1]==NULL ||
           ( command->argv[2]!=NULL && command->argv[3]!=NULL)
         ) {				/* incorrect no of args */
         ierr=-301;
         goto error;
      }

parse:
      /* if we get this far it is a set-up command so parse it */
      ilast=0;                                      /* last argv examined */
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        if ((ierr=ds_dec(&lcl,&count, ptr)) != 0) goto error;
      }

      /* format command into class buffer for dscon */
      for (i=0; i<5; i++) ip[i]=0;
      dscon_snd(&lcl,ip);

      /* activate SDIO controller sub-program */
      run_dscon(ip);

      /* Always display class return from DSCON controller sub-program */
      ds_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ds",2);
      return;
}
