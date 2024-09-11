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
/* rdbe_data_send commmand buffer parsing utilities */

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

static char *status_key[ ]=        { "off","on","waiting"};

#define NSTATUS_KEY sizeof(status_key)/sizeof( char *)

char *m5trim();

int rdbe_data_send_dec(lcl,count,ptr)
  struct rdbe_data_send_cmd *lcl;
  int *count;
  char *ptr;
{
  int ierr, i, arg_key();

  ierr=0;
  if(ptr == NULL) ptr="";

  switch (*count) {
    case 1:
      ierr=arg_key(ptr,status_key,NSTATUS_KEY,&lcl->status.status,-1,FALSE);
      if(0==ierr && 2 ==lcl->status.status)
        ierr=-200;
      if(0==ierr) {
        m5state_init(&lcl->status.state);
        lcl->status.state.known=1;
      }
      break;
    case 2:
      if(0==strcmp(ptr,"*"))
        break;
      m5state_init(&lcl->start.state);
      if(ptr==NULL || *ptr==0)
        lcl->start.start[0]=0;
      else if (strlen(ptr) > sizeof(lcl->start.start)-1)
        ierr=-200;
      else {
        struct tm tm;
        char *ptr2=strptime(ptr, "%Y-%j-%H-%M-%S", &tm);
       if(NULL==ptr2 || *ptr2!=0)
          ierr=-200;
        else {
          strcpy(lcl->start.start,ptr);
          lcl->start.state.known=1;
        }
      }
      break;
    case 3:
      if(0==strcmp(ptr,"*"))
        break;
      m5state_init(&lcl->end.state);
      if(ptr==NULL || *ptr==0)
        lcl->end.end[0]=0;
      else if(0==strcmp(ptr,"*"))
        ;
      else if (strlen(ptr) > sizeof(lcl->end.end)-1)
        ierr=-200;
      else {
        struct tm tm;
        char *ptr2=strptime(ptr, "%Y-%j-%H-%M-%S", &tm);
        if(NULL==ptr2 || *ptr2!=0)
          ierr=-200;
        else {
          strcpy(lcl->end.end,ptr);
          lcl->end.state.known=1;
        }
      }
      break;
    case 4:
      ierr=arg_int(ptr,&lcl->delta.delta,0,FALSE);
      m5state_init(&lcl->delta.state);
      if(ierr==-100) {
        ierr=0;
      } else if(ierr==0 && lcl->delta.delta <= 0)
        ierr=-200;
      else if(ierr == 0)
        lcl->delta.state.known=1;
      break;
    default:
      *count=-1;
  }

  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void rdbe_data_send_enc(output,count,lclc)
  char *output;
  int *count;
  struct rdbe_data_send_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5key_encode(output,status_key,NSTATUS_KEY,
          lclc->status.status,&lclc->status.state);
      break;
    case 2:
      m5sprintf(output,"%s",lclc->start.start,&lclc->start.state);
      break;
    case 3:
      m5sprintf(output,"%s",lclc->end.end,&lclc->end.state);
      break;
    case 4:
      m5sprintf(output,"%d",&lclc->delta.delta,&lclc->delta.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
void rdbe_data_send_mon(output,count,lclm)
  char *output;
  int *count;
  struct rdbe_data_send_mon *lclm;
{
  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5sprintf(output,"%s",&lclm->dot.dot,&lclm->dot.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclm->delta_start.delta_start,&lclm->delta_start.state);
      break;
    case 3:
      m5sprintf(output,"%d",&lclm->delta_stop.delta_stop,&lclm->delta_stop.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_data_send_2_rdbe(ptr,lcl)
  char *ptr;
  struct rdbe_data_send_cmd *lcl;
{
  strcpy(ptr,"dbe_data_send = ");

  if(lcl->status.status >= 0 && lcl->status.status <NSTATUS_KEY) {
    strcat(ptr,status_key[lcl->status.status]);
  }

  if(lcl->start.state.known || lcl->end.state.known || lcl->delta.state.known) {
    strcat(ptr," : ");
    if(lcl->start.state.known)
      strcat(ptr,lcl->start.start);

    if(lcl->status.state.known || lcl->delta.state.known) {
      strcat(ptr," : ");
      if(lcl->end.state.known)
        strcat(ptr,lcl->end.end);

      if(lcl->delta.state.known) {
        strcat(ptr," : ");
        sprintf(ptr+strlen(ptr),"%d",lcl->delta.delta);
      }
    }
  }

  strcat(ptr," ;\n");

  return;
}
rdbe_2_rdbe_data_send(ptr_in,lclc,lclm,ip) /* return values:
                                            *  0 == no error
                                            *  0 != error
                                            */
  char *ptr_in;           /* input buffer to be parsed */

  struct rdbe_data_send_cmd *lclc;  /* result structure with parameters */
  struct rdbe_data_send_mon *lclm;  /* result structure with parameters */
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

  m5state_init(&lclc->status.state);
  m5state_init(&lclc->start.state);
  m5state_init(&lclc->end.state);
  m5state_init(&lclc->delta.state);
  m5state_init(&lclm->dot.state);
  m5state_init(&lclm->delta_start.state);
  m5state_init(&lclm->delta_stop.state);

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
          if(m5key_decode(ptr,
                &lclc->status.status,status_key,NSTATUS_KEY,
                &lclc->status.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 2:
          if(strlen(ptr)> sizeof(lclc->start.start)-1) {
            ierr=-500-count;
            goto error2;
          } else {
            strcpy(lclc->start.start,ptr);
            lclc->start.state.known=1;
          }
          break;
        case 3:
          if(strlen(ptr)> sizeof(lclc->end.end)-1) {
            ierr=-500-count;
            goto error2;
          } else {
            strcpy(lclc->end.end,ptr);
            lclc->end.state.known=1;
          }
          break;
        case 4:
          if(strlen(ptr)> sizeof(lclm->dot.dot)-1) {
            ierr=-500-count;
            goto error2;
          } else {
            strcpy(lclm->dot.dot,ptr);
            lclm->dot.state.known=1;
          }
          break;
        case 5:
          if(m5sscanf(ptr,"%d",&lclm->delta_start.delta_start, &lclm->delta_start.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 6:
          if(m5sscanf(ptr,"%d",&lclm->delta_stop.delta_stop, &lclm->delta_stop.state)) {
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
  memcpy(ip+3,"2c",2);
  return -1;
}
