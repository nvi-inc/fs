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
/* tpicd snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>


#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void tpicd(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct tpicd_cmd lcl;

      int tpicd_dec();                 /* parsing utilities */
      char *arg_next();

      void tpicd_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {           /* run pcald */
	if(RDBE!=shm_addr->equip.rack) {
	  for(i=0;i<MAX_GLOBAL_DET;i++)
	    if(0!=shm_addr->tpicd.itpis[i])
	      goto Start;
	  ierr=-302;
	  goto error;
	}
      Start:
	  shm_addr->tpicd.stop_request=0;
	  shm_addr->tpicd.tsys_request=0;
	  skd_run("tpicd",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
      } else if (command->argv[0]==NULL) {
	goto parse;  /* simple equals */
      } else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          tpicd_dis(command,ip);
	  return;
	} else if(0==strcmp(command->argv[0],"stop")){
	  shm_addr->tpicd.stop_request=1;
	  skd_run("tpicd",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
          return;
	} else if(0==strcmp(command->argv[0],"tsys")){
	  if((DBBC==shm_addr->equip.rack && 0==shm_addr->dbbc_cont_cal.mode)||
	     (DBBC3==shm_addr->equip.rack && 0==shm_addr->dbbc3_cont_cal.mode)) {
	    ierr=-301;
	    goto error;
	  }
	  if(RDBE!=shm_addr->equip.rack) {
	    for(i=0;i<MAX_GLOBAL_DET;i++)
	      if(0!=shm_addr->tpicd.itpis[i])
		goto Tsys;
	    ierr=-302;
	    goto error;
	  }
	  if(shm_addr->equip.rack==DBBC && 
	     (shm_addr->equip.rack_type == DBBC_DDC ||
	      shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
	    if(0==shm_addr->dbbc_cont_cal.mode) {
	      ierr=-301;
	      goto error;
	    }
	  } else {
	    ierr=-303;
	    goto error;
	  }

	if(RDBE!=shm_addr->equip.rack) {
	  for(i=0;i<MAX_GLOBAL_DET;i++)
	    if(0!=shm_addr->tpicd.itpis[i])
	      goto Tsys;
	  ierr=-302;
	  goto error;
	}
	Tsys:
	  shm_addr->tpicd.tsys_request=1;
	  skd_run("tpicd",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
          return;
	} else if(0==strcmp(command->argv[0],"display_on")) {
	  int val;
	  memcpy(&val,"pn",2);
	  cls_snd(&shm_addr->iclbox,0,0,0,val);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
	} else if(0==strcmp(command->argv[0],"display_off")) {
	  int val;
	  memcpy(&val,"pf",2);
	  cls_snd(&shm_addr->iclbox,0,0,0,val);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
	}
      }
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      memcpy(&lcl,&shm_addr->tpicd,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=tpicd_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->tpicd,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=0;

      tpicd_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"tc",2);
      return;
}
