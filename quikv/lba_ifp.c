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
/* lba das ifp snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void lba_ifp(command,itask,ip)
struct cmd_ds *command;               /* parsed command structure */
int itask;                            /* sub-task, ifp number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, count;
      char *ptr;
      struct ifp lcl;              /* local instance of ifp command struct */

      int lba_ifp_dec();               /* parsing utilities */
      char *arg_next();

      int lba_ifp_setup(), lba_ifp_write(), lba_ifp_read();  /* ifp utilities */
      void lba_ifp_dis();

      ichold= -99;                    /* check value holder */

      ind=itask-1;                    /* index for this module */
      if (ind/2 >= shm_addr->n_das) {
          ierr = -903;
          goto error;
      }
      ierr = 0;

      if (command->equal != '=') {            /* read module */
         goto monitor;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL) {  /* special cases */
            if (*command->argv[0]=='?') {
               lba_ifp_dis(command,itask,ip);
               return;
            } else if(0==strcmp(command->argv[0],"alarm")) {
               ierr=reset_err_flags(itask-1);
               if(ierr !=0 ) goto error;
               lba_ifp_dis(command,itask,ip);
               return;
            }
      } else if ( command->argv[1] != NULL && command->argv[2] != NULL &&
                  command->argv[3] != NULL && command->argv[4] != NULL &&
                  command->argv[5] != NULL && command->argv[6] != NULL &&
                  command->argv[7] != NULL ) {
         ierr=-301;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->das[ind/2].ifp[ind%2],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=lba_ifp_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }
      ierr=lba_ifp_setup(&lcl,ind);
      if(ierr !=0 ) goto error;

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.ifp[ind];
      shm_addr->check.ifp[ind]=0;
      memcpy(&shm_addr->das[ind/2].ifp[ind%2],&lcl,sizeof(lcl));
      
      if ((ierr=lba_ifp_write(ind)) != 0) {
         ierr = -901;
      }

      if (ichold != -99) {
         rte_rawt(shm_addr->check.ifp_time+ind);
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.ifp[ind]=ichold;
      }
      if (ierr !=0 ) goto error;

monitor:
      ichold=shm_addr->check.ifp[ind];
      shm_addr->check.ifp[ind]=0;

      if (shm_addr->das[ind/2].ifp[ind%2].initialised &&
		(ierr=lba_ifp_read(ind,FALSE)) != 0) {
         ierr = -902;
      }

      if (ichold != -99) {
         rte_rawt(shm_addr->check.ifp_time+ind);
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.ifp[ind]=ichold;
      }
      if (ierr !=0 ) goto error;

      lba_ifp_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"li",2);
      return;
}
