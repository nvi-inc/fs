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
/* mk5 SD SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void disk_record_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      int out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      int kcom;
      int iclass, nrecs;
      struct disk_record_cmd lclc;
      struct disk_record_mon lclm;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if((!kcom) && command->equal == '=') {
	if(0!=logm5msg(output,command,ip)) {
	  ip[2]=-400;
	  memcpy(ip+3,"5r",2);
	  return;
	}
	return;
      } else if(kcom) {
         memcpy(&lclc,&shm_addr->disk_record,sizeof(lclc));
      } else {
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
	    if(0!=m5_2_disk_record(inbuf,&lclc,&lclm,ip)) {
	      goto error;
	    }
	}
      }
   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        disk_record_enc(output,&count,&lclc,&lclm);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          disk_record_mon(output,&count,&lclm);
        }
      }
      if(strlen(output)>0) output[strlen(output)-1]='\0';

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;
      return;

error2:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5r",2);
error:
      cls_clr(iclass);
      return;
}


