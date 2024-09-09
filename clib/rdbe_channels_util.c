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
/* rdbe_channels commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>
#define _XOPEN_SOURCE
#include <time.h>

static char *both_key[ ]=         { "both"};
static char   *if_key[ ]=         { "0", "1"};
#define NBOTH_KEY sizeof(both_key)/sizeof( char *)
#define NIF_KEY sizeof(if_key)/sizeof( char *)

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

char *m5trim();

int rdbe_channels_dec(lcl,ifc,count,ptr)
  struct rdbe_channels_cmd *lcl;
  int *ifc;
  int *count;
  char *ptr;
{
  int ierr, arg_key();

  ierr=0;
  if(*count==1) {
    ierr=arg_key(ptr,both_key,NBOTH_KEY,ifc,-1,TRUE);
    if(0==ierr)
	    *ifc=-1;
	  else
	    ierr=arg_key(ptr,if_key,NIF_KEY,ifc,-1,TRUE);
    if(ierr==0) {
      int j;
      for (j=0;j<MAX_RDBE_IF;j++)  {
        if(*ifc==-1||*ifc==j) {
          int i;
          lcl->ifc[j].ifc.ifc=j;
          m5state_init(&lcl->ifc[j].ifc.state);
          lcl->ifc[j].ifc.state.known=1;
          for (i=0;i<MAX_R2DBE_CH;i++)
            lcl->ifc[j].channels.channels[i]=-1;
          m5state_init(&lcl->ifc[j].channels.state);
          lcl->ifc[j].channels.state.known=1;
        }
      }
    }
  } else if(ptr==NULL) {
    if(*count==2)
      ierr=-100;
    else
      *count=-1;
  } else {
    if(*count-1>MAX_R2DBE_CH)
      ierr=-300;
    else {
      int ich;
      ierr=arg_int(ptr,&ich,-1,FALSE);
      if(ierr==0)
        if (ich<0 || ich>=MAX_R2DBE_CH)
          ierr=-200;
        else {
          int j;
          for (j=0;j<MAX_RDBE_IF;j++)
            if(*ifc==-1||*ifc==j)
              lcl->ifc[j].channels.channels[*count-2]=ich;
        }
    }
  }

  if(ierr!=0) {
    if(*count > 1)
      ierr-=2;
    else
      ierr-=*count;
  }
  if(*count>0) (*count)++;
  return ierr;
}

void rdbe_channels_enc(output,count,lclc,ifc)
  char *output;
  int *count;
  struct rdbe_channels_cmd *lclc;
  int ifc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      if(lclc->ifc[ifc].ifc.ifc >= 0 && lclc->ifc[ifc].ifc.ifc <NIF_KEY)
        m5key_encode(output,if_key,NIF_KEY,
            lclc->ifc[ifc].ifc.ifc,&lclc->ifc[ifc].ifc.state);
      else
        strcat(output,BAD_VALUE);
      break;
    case 2:
      if(lclc->ifc[ifc].channels.state.known) {
        int i;
        for (i=0;i<MAX_R2DBE_CH && lclc->ifc[ifc].channels.channels[i]!=-1; i++) {
          sprintf(output,"%d,",lclc->ifc[ifc].channels.channels[i]);
          output=output+strlen(output);
        }
      }
      *count=-1;
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_channels_2_rdbe(ptr,lcl,ifc)
  char *ptr;
  struct rdbe_channels_cmd *lcl;
  int ifc;
{
  strcpy(ptr,"dbe_chsel = ");

  ptr+=strlen(ptr);
  sprintf(ptr,"%d ",ifc);
  if(lcl->ifc[ifc].channels.state.known) {
    int i;
    for(i=0;i<MAX_R2DBE_CH && lcl->ifc[ifc].channels.channels[i]!=-1;i++) {
      ptr+=strlen(ptr);
      sprintf(ptr,": %d ",lcl->ifc[ifc].channels.channels[i]);
    }
  }

  strcat(ptr,";\n");

  return;
}
rdbe_2_rdbe_channels(ptr_in,lclc,ip,irec) /* return values:
                                            *  0 == no error
                                            *  0 != error
                                            */
  char *ptr_in;           /* input buffer to be parsed */

  struct rdbe_channels_cmd *lclc;  /* result structure with parameters */
  int ip[5];   /* standard parameter array */
  int irec;
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int ifc, ich;
  char ch;
  int i;

  m5state_init(&lclc->ifc[irec].ifc.state);
  m5state_init(&lclc->ifc[irec].channels.state);
  for(i=0;i<MAX_R2DBE_CH;i++)
    lclc->ifc[irec].channels.channels[i]=-1;

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
          if(m5key_decode(ptr,
                &lclc->ifc[irec].ifc.ifc,if_key,NIF_KEY,
                &lclc->ifc[irec].ifc.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        default:
          if(1!=sscanf(ptr,"%d",&ich)||ich<0||ich>MAX_R2DBE_CH) {
            ierr=-502;
            goto error2;
          }
          lclc->ifc[irec].channels.state.known=1;
          lclc->ifc[irec].channels.channels[count-2]=ich;
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
  ip[2]=ierr-10*irec;
  memcpy(ip+3,"2d",2);
  return -1;
}
