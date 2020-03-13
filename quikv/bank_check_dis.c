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
/* mk5 bank_check SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void bank_check_dis(command,itask,ip,increment)
struct cmd_ds *command;
int itask, increment;
int ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars, iclass,nrecs;
      int out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      int len;
      struct vsn_mon vsn_mon;
      struct disk_serial_mon disk_serial_mon;
      char vsn[8];

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
	  goto error;
	}
	
	if(i==0) {
	  if(0!=m5_2_vsn(inbuf,&vsn_mon,ip)) {
	    goto error;
	  }
	  len=sizeof(shm_addr->mk5vsn)-1;
	  if(increment==FALSE &&
	     strncmp(vsn_mon.vsn.vsn,shm_addr->mk5vsn,len)==0 &&
	     shm_addr->mk5vsn_logchg == shm_addr->logchg) {
	    cls_clr(iclass);
	    goto done;
	  }
	} else if(i==1) {
	  if(0!=m5_2_disk_serial(inbuf,&disk_serial_mon,ip)) {
	    goto error;
	  }
	}
      }
	  
      strncpy(shm_addr->mk5vsn,vsn_mon.vsn.vsn,sizeof(shm_addr->mk5vsn));
      shm_addr->mk5vsn_logchg = shm_addr->logchg;
      len=strlen(vsn_mon.vsn.vsn);
      if(len>sizeof(shm_addr->mk5vsn)-1)
	shm_addr->mk5vsn[sizeof(shm_addr->mk5vsn)-1]=0;

      m5sprintf(output+strlen(output),"%s",vsn_mon.vsn.vsn,
		&vsn_mon.vsn.state);

      /* check for correct VSN form */

      memcpy(vsn,vsn_mon.vsn.vsn,sizeof(vsn));
      vsn[sizeof(vsn)-1]=0;
      if(NULL == strchr(vsn,'+') && NULL==strchr(vsn,'-'))
	logit(NULL,-302,"5b");
      
      for (i=0;i<disk_serial_mon.count;i++) {
	strcat(output,",");
	m5sprintf(output+strlen(output),"%s",disk_serial_mon.serial[i].serial,
		&disk_serial_mon.serial[i].state);
      }

      cls_snd(&out_class,output,strlen(output),0,0);
      out_recs++;

 done:
      ip[0]=out_class;
      ip[1]=out_recs;
      ip[2]=0;

      return;

error:
      cls_clr(iclass);
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5b",2);
      return;
}
