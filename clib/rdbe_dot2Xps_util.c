/*
 * Copyright (c) 2024, 2025 NVI, Inc.
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
/* rdbe dot2gps and dot2pps commmand buffer parsing utilities */

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

void rdbe_dot2Xps_mon(output,count,lclm,irdbe)
char *output;
int *count;
struct rdbe_dot2Xps_mon *lclm;
int irdbe;
{
  int i;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      if(lclm->offset.state.known == 1) {
        if(shm_addr->equip.rack_type == RDBE)
          sprintf(output,"%.9e",lclm->offset.offset);
        else
          sprintf(output,"%.6e",lclm->offset.offset);
      }
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_2_rdbe_dot2Xps(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rdbe_dot2Xps_mon *lclm;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  float level;
  char ch;
  int ich;

  m5state_init(&lclm->offset.state);

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
          if(m5sscanf(ptr,"%lf", &lclm->offset.offset,&lclm->offset.state)) {
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
  memcpy(ip+3,"2g",2);
  return -1;
}
