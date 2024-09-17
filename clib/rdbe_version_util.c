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
/* rdbe rdbe_version commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */


char *m5trim();

void rdbe_version_mon(output,count,lclm,irdbe)
char *output;
int *count;
struct rdbe_version_mon *lclm;
int irdbe;
{
  int i;

  if(shm_addr->equip.rack_type == RDBE && *count >= 3) {
     *count=-1;
     return;
  }

  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5sprintf(output,"%s",&lclm->app.app,&lclm->app.state);
      break;
    case 2:
      m5sprintf(output,"%s",&lclm->os.os,&lclm->os.state);
      break;
    case 3:
      m5sprintf(output,"%s",&lclm->roach.roach,&lclm->roach.state);
      break;
    case 4:
      m5sprintf(output,"%s",&lclm->timing.timing,&lclm->timing.state);
      break;
    case 5:
      m5sprintf(output,"%s",&lclm->fpga.fpga,&lclm->fpga.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_2_rdbe_version(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rdbe_version_mon *lclm;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  float level;
  char ch;
  int ich;

  m5state_init(&lclm->app.state);
  m5state_init(&lclm->os.state);
  m5state_init(&lclm->roach.state);
  m5state_init(&lclm->timing.state);
  m5state_init(&lclm->fpga.state);

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL)
    ptr=strchr(ptr_in,'=');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }
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
          if(strlen(ptr)+1>sizeof(lclm->app.app)) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclm->app.app,ptr);
          lclm->app.state.known=1;
          break;
        case 2:
          if(strlen(ptr)+1>sizeof(lclm->os.os)) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclm->os.os,ptr);
          lclm->os.state.known=1;
          break;
        case 3:
          if(strlen(ptr)+1>sizeof(lclm->roach.roach)) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclm->roach.roach,ptr);
          lclm->roach.state.known=1;
          break;
        case 4:
          if(strlen(ptr)+1>sizeof(lclm->timing.timing)) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclm->timing.timing,ptr);
          lclm->timing.state.known=1;
          break;
        case 5:
          if(strlen(ptr)+1>sizeof(lclm->fpga.fpga)) {
            ierr=-500-count;
            goto error2;
          }
          strcpy(lclm->fpga.fpga,ptr);
          lclm->fpga.state.known=1;
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
  memcpy(ip+3,"2i",2);
  return -1;
}