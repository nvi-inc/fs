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
/* mk6 SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 512
#define BUFSIZE 513

extern char unit_letters[];

void mk6_dis(command,itask,iwhich,ip,out_class,out_recs)
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
      char inbuf[BUFSIZE],*first;
      int n;
      char who[3];

   /* format output buffer */

      if(itask == 0)
	sprintf(output,"%s%c",command->name,unit_letters[iwhich]);
      else
	strcpy(output,command->name);

      strcat(output,"/");
      start=output+strlen(output);

      for (i=0;i<ip[1];i++) {
	if ((nchars =
	     cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ierr = -401;
	  goto error;
	}
	inbuf[nchars]=0;

	first=inbuf;
	while(strlen(first)>0) {
	  *start=0;
	  if(strlen(first)+1<=sizeof(output)-strlen(output)) {
	    strcpy(start,first);
	    if(strlen(output)>0 && output[strlen(output)-1]=='\n')
	      output[strlen(output)-1]='\0';
	    first+=strlen(first);
	  } else {
	    int last;
	    n=sizeof(output)-strlen(output)-1;
	    for(last=n;last>(n-35) && last>0;last--) {
	      if(first[last-1]==':') {
		n=last;
		break;
	      }
	    }
	    if(index(":",first[n-1])==NULL)
	      for(last=n;last>(n-35) && last>0;last--) {
		if(first[last-1]==',') {
		  n=last;
		  break;
		}
	      }
	    if(index(":,",first[n-1])==NULL)
	      for(last=n;last>(n-35) && last>1;last--) {
		if(first[last-1]==' ') {
		  n=last-1;
		  break;
		}
	      }
	    strncpy(start,first,n);
	    start[n]=0;
	    first+=n;
	  }
	  if(strlen(start)>0) {
	    cls_snd(out_class,output,strlen(output),0,0);
	    (*out_recs)++;
	  }
	}
      }

      return;

error:
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=0;
      if(ip[2]!=0)
	logit(NULL,ip[2],ip+3);
      ip[2]=ierr;
      memcpy(ip+3,"3m",2);
      snprintf(who,3,"c%c",unit_letters[iwhich]);
      memcpy(ip+4,who,2);
      return;
}
