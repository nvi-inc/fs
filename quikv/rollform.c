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
/* makr IV rollform snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void rollform(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, i, count, j;
      char *ptr;
      struct form4_cmd lcl;     /* local instance of form command struc */

      int rollform_dec();                 /* parsing utilities */
      char *arg_next();

      void rollform_dis();

      ierr = 0;
      memcpy(&lcl,&shm_addr->form4,sizeof(lcl));

      if (command->equal != '=') {            /* display table */
	 rollform_dis(command,&shm_addr->form4,ip);
	 return;
      } else if (command->argv[0]==NULL) { /* simple equals */
	for (j=0;j<15;j++) {
	  for (i=0;i<64;i++) 
	    lcl.roll[j][i]=-2;
	}
	lcl.start_map=-1;
	lcl.end_map=-1;
	lcl.barrel=0;
	goto copy;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=rollform_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */
copy:
      memcpy(&shm_addr->form4,&lcl,sizeof(lcl));
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"4r",2);
      return;
}
