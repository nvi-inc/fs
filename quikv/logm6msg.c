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
#include <string.h>
#include <sys/types.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define BUFSIZE 2048
extern char unit_letters[];

logm6msg(output,command,itask,iwhich,ip,out_class,out_recs)
char *output;
struct cmd_ds *command;
int itask,iwhich;
int ip[5];
int *out_class;
int *out_recs;
{
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE];
  int i;

 /* format output buffer */

  if(itask == 0 && iwhich!=0)
    sprintf(output,"%s%c",command->name,unit_letters[iwhich]);
  else
    strcpy(output,command->name);
  strcat(output,"/");
 
  for (i=0;i<ip[1];i++) {
    char *ptr;
    if ((nchars =
	 cls_rcv(ip[0],inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
      goto error;
    }
    if(i!=0)
      strcat(output,",");
    strcat(output,"ack");
  }
    
  cls_snd(out_class,output,strlen(output),0,0);
  (*out_recs)++;
  
  ip[2]=0;
  
  return 0;

error:
  cls_clr(ip[0]);
  return -1;
}
