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
/* RDBE personality commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
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

int rdbe_personality_dec(lcl,count,ptr)
  struct rdbe_personality_cmd *lcl;
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
      if(!some) {
        strcpy(lcl->type.type,"PFBG");
        lcl->type.state.known=1;
      } else if(strlen(ptr)> sizeof(lcl->type.type)-1)
        ierr=-200;
      else if(0!=strcmp(ptr,"*")){
        strcpy(lcl->type.type,ptr);
        m5state_init(&lcl->type.state);
        lcl->type.state.known=1;
      }
      break;
    case 2:
      some=FALSE;
      for (i=0;i<strlen(ptr); i++) {
        some=!isspace(ptr[i]);
        break;
      }
      if(!some) {
        strcpy(lcl->file.file,"PFBG_3_0.bin");
        lcl->file.state.known=1;
      } else if(strlen(ptr)> sizeof(lcl->file.file)-1)
        ierr=-200;
      else if(0!=strcmp(ptr,"*")){
        strcpy(lcl->file.file,ptr);
        m5state_init(&lcl->file.state);
        lcl->file.state.known=1;
      }
      break;
    default:
      *count=-1;
  }

  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void rdbe_personality_enc(output,count,lclc)
  char *output;
  int *count;
  struct rdbe_personality_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5sprintf(output,"%s",&lclc->type.type,&lclc->type.state);
      break;
    case 2:
      m5sprintf(output,"%s",lclc->file.file,&lclc->file.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
void rdbe_personality_mon(output,count,lclm)
  char *output;
  int *count;
  struct rdbe_personality_mon *lclm;
{
  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5sprintf(output,"%s",&lclm->status.status,&lclm->status.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclm->board.board,&lclm->board.state);
      break;
    case 3:
      m5sprintf(output,"%d",&lclm->major.major,&lclm->major.state);
      break;
    case 4:
      m5sprintf(output,"%d",&lclm->minor.minor,&lclm->minor.state);
      break;
    case 5:
      m5sprintf(output,"%d",&lclm->rcs.rcs,&lclm->rcs.state);
      break;
    case 6:
      m5sprintf(output,"%s",&lclm->fpga.fpga,&lclm->fpga.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_personality_2_rdbe(ptr,lcl)
  char *ptr;
  struct rdbe_personality_cmd *lcl;
{
  strcpy(ptr,"dbe_personality = ");

  if(lcl->type.state.known)
    strcat(ptr,lcl->type.type);
  strcat(ptr," : ");

  if(lcl->file.state.known)
    strcat(ptr,lcl->file.file);

  strcat(ptr," ;\n");

  return;
}
int rdbe_2_rdbe_personality(ptr_in,lclc,lclm,ip) /* return values:
                                            *  0 == no error
                                            *  0 != error
                                            */
  char *ptr_in;           /* input buffer to be parsed */

  struct rdbe_personality_cmd *lclc;  /* result structure with parameters */
  struct rdbe_personality_mon *lclm;  /* result structure with parameters */
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

  m5state_init(&lclc->type.state);
  m5state_init(&lclc->file.state);
  m5state_init(&lclm->status.state);
  m5state_init(&lclm->board.state);
  m5state_init(&lclm->major.state);
  m5state_init(&lclm->minor.state);
  m5state_init(&lclm->rcs.state);
  m5state_init(&lclm->fpga.state);

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
          if(strlen(ptr)> sizeof(lclc->type.type)-1) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclc->type.type,ptr);
          lclc->type.state.known=1;
          break;
        case 2:
          if(strlen(ptr)> sizeof(lclc->file.file)-1) {
            ierr=-500-count;
            goto error2;
          } else {
            strcpy(lclc->file.file,ptr);
            lclc->file.state.known=1;
          }
          break;
        case 3:
          if(strlen(ptr)> sizeof(lclm->status.status)-1) {
            ierr=-500-count;
            goto error2;
          } else {
            strcpy(lclm->status.status,ptr);
            lclm->status.state.known=1;
          }
          break;
        case 4:
          if(m5sscanf(ptr,"%d", &lclm->board.board,&lclm->board.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 5:
          if(m5sscanf(ptr,"%d", &lclm->major.major,&lclm->major.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 6:
          if(m5sscanf(ptr,"%d", &lclm->minor.minor,&lclm->minor.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 7:
          if(m5sscanf(ptr,"%d", &lclm->rcs.rcs,&lclm->rcs.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        case 8:
          if(strlen(ptr)> sizeof(lclm->fpga.fpga)-1) {
            ierr=-500-count;
            goto error2;
          } else {
            strcpy(lclm->fpga.fpga,ptr);
            lclm->fpga.state.known=1;
          }
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
  memcpy(ip+3,"2k",2);
  return -1;
}
