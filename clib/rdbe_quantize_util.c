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
/* rdbe_quantize commmand buffer parsing utilities */

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

static char *both_key[ ]=         { "both"};
static char   *if_key[ ]=         { "0", "1"};
static char  *all_key[ ]=         { "all"};

#define NBOTH_KEY sizeof(both_key)/sizeof( char *)
#define NIF_KEY sizeof(if_key)/sizeof( char *)
#define NALL_KEY sizeof(all_key)/sizeof( char *)

char *m5trim();

int rdbe_quantize_dec(lcl,count,ptr)
struct rdbe_quantize_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        m5state_init(&lcl->ifc.state);
        ierr=arg_key(ptr,both_key,NBOTH_KEY,&lcl->ifc.ifc,-1,TRUE);
        if(0==ierr) {
          lcl->ifc.ifc=-1;
        } else {
          ierr=arg_key(ptr,if_key,NIF_KEY,&lcl->ifc.ifc,-1,TRUE);
        }
        if(0==ierr)
          lcl->ifc.state.known=1;
        break;
      case 2:
        m5state_init(&lcl->channel.state);
        ierr=arg_key(ptr,all_key,NALL_KEY,&lcl->channel.channel,-1,TRUE);
        if(0==ierr) {
          lcl->channel.channel=-1;
        } else {
          ierr=arg_int(ptr,&lcl->channel.channel,-1,FALSE);
          if(ierr==0 && (lcl->channel.channel<0 ||lcl->channel.channel>=MAX_R2DBE_CH))
            ierr=-200;
        }
        if(0==ierr)
          lcl->channel.state.known=1;
        break;
      case 3:
        m5state_init(&lcl->threshold.state);
        ierr=arg_uns(ptr,&lcl->threshold.threshold,0,FALSE);
        if(ierr==-100)
          ierr=0;
        else if(ierr==0)
          lcl->threshold.state.known=1;
        break;
      default:
        *count=-1;
    }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void rdbe_quantize_enc(output,count,lclc)
char *output;
int *count;
struct rdbe_quantize_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      if(lclc->ifc.state.known == 1)
        if(lclc->ifc.ifc >= 0 && lclc->ifc.ifc <NIF_KEY) {
          m5key_encode(output,if_key,NIF_KEY,
              lclc->ifc.ifc,&lclc->ifc.state);
        } else if(lclc->ifc.ifc == -1) {
          strcat(output,both_key[0]);
        } else
          strcat(output,BAD_VALUE);
      break;
    case 2:
      if(lclc->channel.state.known == 1)
        if(lclc->channel.channel >= 0) {
          sprintf(output,"%d",lclc->channel.channel);
          m5state_encode(output,&lclc->channel.state);
        } else if(lclc->channel.channel == -1) {
          strcat(output,all_key[0]);
        } else
          strcat(output,BAD_VALUE);
      break;
    case 3:
      if(lclc->threshold.state.known == 1)  {
        sprintf(output,"%u",lclc->threshold.threshold);
        m5state_encode(output,&lclc->threshold.state);
      }
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
void rdbe_quantize_mon(output,count,lclm,irdbe,ifc)
char *output;
int *count;
struct rdbe_quantize_mon *lclm;
int irdbe;
int ifc;
{
  int i;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      if(lclm->ifc[ifc].ifc.state.known == 1)
        if(lclm->ifc[ifc].ifc.ifc >= 0 && lclm->ifc[ifc].ifc.ifc <NIF_KEY) {
          strcat(output,",,,");
          output=output+strlen(output);
          m5key_encode(output,if_key,NIF_KEY,
              lclm->ifc[ifc].ifc.ifc,&lclm->ifc[ifc].ifc.state);
        } else {
          strcat(output,BAD_VALUE);
        }
      break;
    case 2:
      if(lclm->ifc[ifc].levels.state.known) {
        int i,total;

        if(shm_addr->equip.rack_type == RDBE)
          total=MAX_RDBE_CH;
        else
          total=MAX_R2DBE_CH;

        if(shm_addr->rdbe_channels[irdbe].ifc[ifc].channels.state.known) {
          for (i=0; i<total && shm_addr->rdbe_channels[irdbe].ifc[ifc].channels.channels[i]!=-1; i++) {
            int channel=shm_addr->rdbe_channels[irdbe].ifc[ifc].channels.channels[i];
            sprintf(output+strlen(output),"%4d,",lclm->ifc[ifc].levels.levels[channel]);
          }
          output[strlen(output)-1]='\0';
        } else {
          for (i=0; i<total; i++)
            sprintf(output+strlen(output),"%4d,",lclm->ifc[ifc].levels.levels[i]);

          output[strlen(output)-1]='\0';
        }
      }
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_quantize_2_rdbe(ptr,lcl)
char *ptr;
struct rdbe_quantize_cmd *lcl;
{
  strcpy(ptr,"dbe_quantize = ");

  if(lcl->ifc.ifc >= 0 && lcl->ifc.ifc <NIF_KEY) {
      strcat(ptr,if_key[lcl->ifc.ifc]);
 }

  if(lcl->channel.channel >= 0 && lcl->channel.channel < MAX_R2DBE_CH) {
    strcat(ptr," : ");
    sprintf(ptr+strlen(ptr),"%d",lcl->channel.channel);
  }
  if(lcl->threshold.state.known) {
    strcat(ptr," : ");
    sprintf(ptr+strlen(ptr),"%d",lcl->threshold.threshold);
  }

  strcat(ptr," ;\n");

  return;
}
rdbe_2_rdbe_quantize(ptr_in,lclm,ip,irec) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rdbe_quantize_mon *lclm;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
     int irec;
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  static int ifc;
  unsigned level;
  char ch;
  int ich;

  m5state_init(&lclm->ifc[irec].ifc.state);
  m5state_init(&lclm->ifc[irec].levels.state);

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
                &lclm->ifc[irec].ifc.ifc,if_key,NIF_KEY,
                &lclm->ifc[irec].ifc.state)) {
            ierr=-500-count;
            goto error2;
          }
          break;
        default:
          if(1!=sscanf(ptr,"%u",&level,&ch)) {
            ierr=-502;
            goto error2;
          }
          if(count-2>MAX_R2DBE_CH-1) {
            ierr=-503;
            goto error2;
          }
          lclm->ifc[irec].levels.state.known=1;
          lclm->ifc[irec].levels.levels[count-2]=level;
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
  memcpy(ip+3,"2e",2);
  return -1;
}
