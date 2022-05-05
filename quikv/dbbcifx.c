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
/* dbbcifX snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbcifx(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, count;
      char *ptr;
      struct dbbcifx_cmd lcl;      /* local instance of dbbcnn command struct */
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      int dbbcifx_dec();               /* parsing utilities */
      char *arg_next();

      void dbbcifx_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */
      static char ifx[] = {"abcd"};


      ind=itask-1;                    /* index for this module */

      if(ind>=shm_addr->dbbc_cond_mods) {
	ierr=-400;
	goto error;
      }

      if (command->equal != '=') {            /* read module */
	out_recs=0;
	out_class=0;

	sprintf(outbuf,"dbbcif%c",ifx[ind]);
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
         goto dbbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  dbbcifx_dis(command,itask,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dbbcifx[ind],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbcifx_dec(&lcl,&count, ptr,itask);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->dbbcifx[ind],&lcl,sizeof(lcl));
      
/* format buffer for dbbcn */
      
      out_recs=0;
      out_class=0;
      dbbcifx_2_dbbc(outbuf,itask,&lcl);

      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

dbbcn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }

      dbbcifx_dis(command,itask,ip);
      return;
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"di",2);
      return;
}
