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
/* dbbc SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 1025
#define BUFSIZE 1025

void dbbc_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      int out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE],*first,*end;
      int n;

   /* format output buffer */

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
	if(*first=='\r')
	  first++;
	while(strlen(first)>0) {
	  *start=0;
	  end=strchr(first,'\n');
	  if(NULL==end) {
	    end=first+strlen(first)-1;
	  }
	  if(1+end-first<=sizeof(output)-strlen(output)) {
	    strncpy(start,first,1+end-first);
	    if(start[end-first]=='\n')
	      start[end-first]=0;
	    else
	      start[1+end-first]=0;
	    first=end+1;
	    if(*first == '\r')
	      first++;
	  } else {
	    n=sizeof(output)-strlen(output)-1;
	    if(1+end-first<n)
	      n=1+end-first;
	    strncpy(start,first,n);
	    start[n]=0;
	    first+=n;
	  }
	  if(strlen(start)>0) {
	    cls_snd(&out_class,output,strlen(output),0,0);
	    out_recs++;
	  }
	}
      }

      ip[0]=out_class;
      ip[1]=out_recs;

      return;

error:
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=0;
      if(ip[2]!=0)
	logit(NULL,ip[2],ip+3);
      ip[2]=ierr;
      memcpy(ip+3,"db",2);
      return;
}
