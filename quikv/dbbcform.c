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
/* dbbcform snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbcform(command,ip)
struct cmd_ds *command;                /* parsed command structure */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr,count;
      char *ptr;
      struct dbbcform_cmd lcl;  /* local instance of dbbcform command struct */
      int out_recs, out_class, ichold;
      char outbuf[BUFSIZE];

      int dbbcform_dec();               /* parsing utilities */
      char *arg_next();

      void dbbcform_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      if(DBBC_DDC != shm_addr->equip.rack_type &&
	 DBBC_DDC_FILA10G != shm_addr->equip.rack_type &&
	 DBBC_PFB != shm_addr->equip.rack_type &&
	 DBBC_PFB_FILA10G != shm_addr->equip.rack_type) {
	ierr=-501;
	goto error;
      }

      if (command->equal != '=') {            /* read module */
	out_recs=0;
	out_class=0;

	strcpy(outbuf,"dbbcform");
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
         goto dbbcn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  dbbcform_dis(command,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dbbcform,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbcform_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      ichold=shm_addr->check.dbbc_form;
      shm_addr->check.dbbc_form=0;

      if(ierr==0 && shm_addr->dbbcddcv<104 && lcl.mode == 5) {
	  ierr=-301;
	  goto error;
      }
      memcpy(&shm_addr->dbbcform,&lcl,sizeof(lcl));
      
/* format buffer for dbbcn */
      
      out_recs=0;
      out_class=0;
      strcpy(outbuf,"version");
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      dbbcform_2_dbbc(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

dbbcn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.dbbc_form=ichold;
      }

      if(ip[2]<0) {
	if(command->equal == '=' && -201 == ip[2]) {
	  logitn(NULL,ip[2],ip+3,ip[4]);
	  ip[2]=-302;
	  memcpy(ip+3,"df",2);
	}
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }

      dbbcform_dis(command,ip);
      return;
      
error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"df",2);
      return;
}
