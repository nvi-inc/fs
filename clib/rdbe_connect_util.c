/*
 * Copyright (c) 2024 NVI, Inc.
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
/* RDBE connect commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>
#define _XOPEN_SOURCE
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

char *m5trim();

int rdbe_connect_dec(lcl,count,ptr)
  struct rdbe_connect_cmd *lcl;
  int *count;
  char *ptr;
{
  int ierr, i, some;

  ierr=0;
  if(ptr == NULL) ptr="";

  switch (*count) {
    case 1:
      some=FALSE;
      for (i=0;i<strlen(ptr); i++) {
        some=!isspace(ptr[i]);
        break;
      }
      if(!some)
        ierr=-100;
      else if(strlen(ptr)> sizeof(lcl->ip.ip)-1)
        ierr=-200;
      else if(0!=strcmp(ptr,"*")){
        strcpy(lcl->ip.ip,ptr);
        m5state_init(&lcl->ip.state);
        lcl->ip.state.known=1;
      }
      break;
    case 2:
      ierr=arg_int(ptr,&lcl->port.port,0,FALSE);
      if(ierr==0 && lcl->port.port <1)
        ierr=-200;
      if(ierr==0) {
        m5state_init(&lcl->port.state);
        lcl->port.state.known=1;
      }
      break;
    case 3:
      ierr=arg_int(ptr,&lcl->station.station,0,FALSE);
      if(ierr==0) {
        m5state_init(&lcl->station.state);
        lcl->station.state.known=1;
      }
      break;
    case 4:
      ierr=arg_int(ptr,&lcl->thread.thread,0,FALSE);
      if(ierr==0 && lcl->thread.thread <0)
        ierr=-200;
      if(ierr==0) {
        m5state_init(&lcl->thread.state);
        lcl->thread.state.known=1;
      }
      break;
    default:
      *count=-1;
  }

  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void rdbe_connect_enc(output,count,lclc)
  char *output;
  int *count;
  struct rdbe_connect_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5sprintf(output,"%s",&lclc->ip.ip,&lclc->ip.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclc->port.port,&lclc->port.state);
      break;
    case 3:
      strcpy(output,"0x");
      output=output+strlen(output);
      m5sprintf(output,"%x",&lclc->station.station,&lclc->station.state);
      break;
    case 4:
      m5sprintf(output,"%d",&lclc->thread.thread,&lclc->thread.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_connect_2_rdbe(ptr,lcl)
  char *ptr;
  struct rdbe_connect_cmd *lcl;
{
  strcpy(ptr,"dbe_data_connect = ");

  if(lcl->ip.state.known)
    strcat(ptr,lcl->ip.ip);
  strcat(ptr," : ");

  if(lcl->port.state.known)
    sprintf(ptr+strlen(ptr),"%d",lcl->port.port);
  strcat(ptr," : ");

  if(lcl->station.state.known)
    sprintf(ptr+strlen(ptr),"0x%x",lcl->station.station);
  strcat(ptr," : ");

  if(lcl->thread.state.known)
    sprintf(ptr+strlen(ptr),"%d",lcl->thread.thread);

  strcat(ptr," ;\n");

  return;
}
rdbe_2_rdbe_connect(ptr_in,lclc,ip) /* return values:
                                            *  0 == no error
                                            *  0 != error
                                            */
  char *ptr_in;           /* input buffer to be parsed */

  struct rdbe_connect_cmd *lclc;  /* result structure with parameters */
  int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  static int ifc;
  char ch;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL)
    ptr=strchr(ptr_in,'=');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  m5state_init(&lclc->ip.state);
  m5state_init(&lclc->port.state);
  m5state_init(&lclc->station.state);
  m5state_init(&lclc->thread.state);

  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logit(NULL,errno,"un");
      ierr=-902;
      goto error;
    }

    ptr2=strchr(ptr,';'); /* terminate the string at the ; */
    if(ptr2!=NULL)
      *ptr2=0;

    count=0;
    ptr_save=ptr;
    ptr=strsep(&ptr_save,":");

    while (ptr!=NULL) {
      switch (++count) {
        case 1:
          if(strlen(ptr)> sizeof(lclc->ip.ip)-1) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclc->ip.ip,ptr);
          lclc->ip.state.known=1;
          break;
        case 2:
          if(m5sscanf(ptr,"%d", &lclc->port.port,&lclc->port.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 3:
          if(m5sscanf(ptr,"%x", &lclc->station.station,&lclc->station.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 4:
          if(m5sscanf(ptr,"%d", &lclc->thread.thread,&lclc->thread.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        default:
          goto done;
          break;
      }
      ptr=strsep(&ptr_save,":");
    }
done:
    free(new_str);
  }
  return 0;

error2:
  free(new_str);
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"2j",2);
  return -1;
}
