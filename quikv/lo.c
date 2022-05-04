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
/* lo snap command */

#include <stdio.h> 
#include <stdlib.h>
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void lo(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct lo_cmd lcl;
      int lo;
      char output[256];
      char *antcn_mode_st;
      int antcn_mode;

      int lo_dec();                 /* parsing utilities */
      char *arg_next();

      void lo_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {           /* read module */
	  lo_dis(command,ip);
	  return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          lo_dis(command,ip);
          return;
	}
    
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->lo,sizeof(lcl));
      count=1;
      lo=-1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=lo_dec(&lcl,&count, ptr,&lo);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->lo,&lcl,sizeof(lcl));

      if(lo!=-1) {
          strcpy(output,command->name);
          strcat(output,"/");
          lo_rxg_enc(output,lo,&lcl);
          logit(output,0,NULL);
          log_rxgfile(lo);
      }

      ip[0]=ip[1]=ip[2]=ierr=0;

      antcn_mode_st=getenv("FS_LO_ANTCN_MODE");
      if (antcn_mode_st && *antcn_mode_st) {
          antcn_mode = atoi(antcn_mode_st);
          if(antcn_mode > 99) {
              ip[0]=antcn_mode;
              ip[3]=lo;
              antcn(ip);
              if(ip[2]<0)
                  return;
          } else
              ierr=-501;
              goto error;
      }
      lo_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q*",2); /* shared with lo_config.c */
      return;
}
