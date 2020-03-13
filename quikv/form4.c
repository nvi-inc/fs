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
/* mark IV formatter snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void form4(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count, nrec, start, end, start_map, j, k;
      int iclass;
      short int buff[80];
      char *ptr;

      struct form4_cmd lcl;          /* local instance of vform command */

      int form4_dec();                 /* parsing utilities */
      char *arg_next();
      int form4ENAma(), form4ASSma(), form4CONma();
      void form4RATma();

      void form4_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      iclass=0;
      nrec=0;

      buff[0]=9;
      memcpy(buff+1,"fm",2);
      buff[2]=0;

      if (command->equal != '=') {            /* read module */

	strcpy((char *) (buff+2),"/STA");
	 cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
	 strcpy((char *) (buff+2),"/SST");
	 cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
	 if(shm_addr->imk4fmv >= 40) {
	   strcpy((char *) (buff+2),"/LIM");
	   cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
	 }

	 if(shm_addr->form4.start_map==-1)
	   start=0;
	 else
	   start=shm_addr->form4.start_map;

	 if(shm_addr->form4.end_map==-1)
	   end=0;
	 else
	   end=shm_addr->form4.end_map;

	 for (j=start;j<end+1;j++) {
	   for (k=0;k<64;k+=16)
	     for (i=k;i<k+16;i++) {
	       int on;
	       if (i <32)
		 on=shm_addr->form4.enable[0] & 1 << i;
	       else
		 on=shm_addr->form4.enable[1] & 1 << (i-32);
	       if(on && shm_addr->form4.a2d[j][i]!=-2) {
		 sprintf((char *) (buff+2),"/SHO %d %d",j, k);
		 cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0);
		 nrec++;
		 break;
	       }
	     }
	 }
         goto matcn;

      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  form4_dis(command,itask,ip);
	  return;
	} 

/* if we get this far it is a set-up command so parse it */

parse:
      ierr=0;
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->form4,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=form4_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->ICHK[16];
      shm_addr->ICHK[16]=0;

      memcpy(&shm_addr->form4,&lcl,sizeof(lcl));

      if(shm_addr->imk4fmv < 40) {
	if(form4CONma(buff,&lcl) < 0) {
	  ierr=-500;
	  goto error;
	}
      }
      strcpy((char *) (buff+2),"/STA");
      cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;

      form4RATma(buff,&lcl);
      cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      
      if(shm_addr->imk4fmv < 40) {
	form4CONma(buff,&lcl);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      } else {
	strcpy((char *) (buff+2),"/FRE");
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      }

      start=start_map=0;
      while(start >= 0) {
	start=form4ASSma(buff,&lcl,start, &start_map);
	if(strlen((char *) (buff+2)) >0) {
	  cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
	}
      }

      if(shm_addr->imk4fmv >= 40) {
	form4ROLma(buff,&lcl);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      }

      strcpy((char *) (buff+2),"/DIS");
      cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;

      start=0;
      while(start >= 0) {
	start=form4ENAma(buff,&lcl,start);
	if(strlen((char *) (buff+2)) >0) {
	  cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
	}
      }
      
      if(shm_addr->imk4fmv >= 40) {
	form4MUXma(buff,&lcl);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;

	form4MODma(buff,&lcl);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      }

      form4LIMma(buff,&lcl);
      cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;

      strcpy((char *) (buff+2),"/CON 0");
      cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;

matcn:
      ip[0]=iclass;
      ip[1]=nrec;
      skd_run("matcn",'w',ip);
      skd_par(ip);
/*
      if (ichold != -99) {
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
	 shm_addr->ICHK[16]=ichold;
      }
*/
      if(ip[2]<0) return;
      form4_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"4f",2);
      return;
}
