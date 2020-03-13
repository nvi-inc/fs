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
/* mk6 disk_pos SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048
 extern char unit_letters[];

void mk6_disk_pos_dis(command,itask,iwhich,ip,out_class,out_recs)
struct cmd_ds *command;
int itask,iwhich;
int ip[5];
int *out_class;
int *out_recs;
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      char inbuf[BUFSIZE];
      struct mk6_disk_pos_mon lclm;
      int iclass, nrecs;
      char who[3];

      snprintf(who,3,"c%c",unit_letters[iwhich]);

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start=output+strlen(output);
      
      iclass=ip[0];
      nrecs=ip[1];

      for (i=0;i<nrecs;i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -401;
	  goto error2;
	}
	if(i==0)
	  if(0!=m5_2_mk6_disk_pos(inbuf,&lclm,ip,who)) {
	    goto error;
	  }
      }

   /* format output buffer */

      if(itask == 0 && iwhich!=0)
	sprintf(output,"%s%c",command->name,unit_letters[iwhich]);
      else
	strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        mk6_disk_pos_mon(output,&count,&lclm);
      }

      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(out_class,output,strlen(output),0,0);
      (*out_recs)++;
      return;

error2:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"3p",2);
      memcpy(ip+4,who,2);
error:
      cls_clr(iclass);
      return;
}
