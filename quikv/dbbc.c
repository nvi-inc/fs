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
/* dbbc SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=' ||
          command->argv[0]==NULL )
         {
         ierr=-301;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      out_recs=0;
      out_class=0;
      ptr=arg_next(command,&ilast);
      outbuf[0]=0;

      while( ptr != NULL) {
	if(22 == itask || 24 == itask)
	  strcat(outbuf,"fila10g=");
	strcat(outbuf,ptr);
	strcat(outbuf,",");
	ptr=arg_next(command,&ilast);
      }
      if(outbuf[0]!=0)
	outbuf[strlen(outbuf)-1]=0;
      cls_snd(&out_class, outbuf, strlen(outbuf), 0, 0);
      out_recs++;

dbbcn:
      if(22==itask || 24 == itask )
	ip[0]=7;
      else if(25==itask)
        ip[0]=8;
      else
	ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      if(20 == itask || 22 == itask || 25==itask)
	skd_run("dbbcn",'w',ip);
      else
	skd_run("dbbc2",'w',ip);
      skd_par(ip);

      dbbc_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"bd",2);
      return;
}
