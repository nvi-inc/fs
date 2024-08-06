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
/* rdbe_pc_offset commmand buffer parsing utilities */

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

static char *status_key[ ]=        { "off","on","waiting"};

#define NSTATUS_KEY sizeof(status_key)/sizeof( char *)

char *m5trim();

int rdbe_pc_offset_dec(lcl,count,ptr,irdbe)
  struct rdbe_pc_offset_cmd *lcl;
  int *count;
  char *ptr;
  int irdbe;
{
  int ierr, i, arg_key();
  double offset;

  ierr=0;
  if(ptr == NULL) ptr="";

  switch (*count) {
    case 1:
      printf(" ptr '%s'\n",ptr);
      offset=lcl->offset.offset;
      ierr=arg_dble(ptr,&offset,0.0,FALSE);
      m5state_init(&lcl->offset.state);
      if(ierr==-100) {
        int ilo=0;
        double spacing,lo;
        if (irdbe!=0)
          ilo=(irdbe-1)*2;
        lo=shm_addr->lo.lo[ilo];
        spacing=shm_addr->lo.spacing[ilo];
        if(lo>=0.0 && spacing>=0) {
          offset=spacing-fmod(lo,spacing);
          ierr=0;
        }
      }
      if(ierr==0) {
        lcl->offset.offset=offset;
        lcl->offset.state.known=1;
      printf(" offset %lf\n",offset);
      }
      break;
    default:
      *count=-1;
  }

  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void rdbe_pc_offset_enc(output,count,lclc)
  char *output;
  int *count;
  struct rdbe_pc_offset_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      m5sprintf(output,"%lf",&lclc->offset.offset,&lclc->offset.state);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_pc_offset_2_rdbe(ptr,lcl)
  char *ptr;
  struct rdbe_pc_offset_cmd *lcl;
{
  strcpy(ptr,"dbe_pcal = ");

  if(lcl->offset.state.known) {
    sprintf(ptr+strlen(ptr),"%lf",lcl->offset.offset);
  }

  strcat(ptr," ;\n");

  return;
}
rdbe_2_rdbe_pc_offset(ptr_in,lclc,ip) /* return values:
                                            *  0 == no error
                                            *  0 != error
                                            */
  char *ptr_in;           /* input buffer to be parsed */

  struct rdbe_pc_offset_cmd *lclc;  /* result structure with parameters */
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
  /* no monitor response */
  m5state_init(&lclc->offset.state);

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
          if(m5sscanf(ptr,"%lf",&lclc->offset.offset, &lclc->offset.state)) {
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
  memcpy(ip+3,"2b",2);
  return -1;
}
