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
/* RDBE chan_sel_en commmand buffer parsing utilities */

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

static char   *rate_key[ ]=        { "2","4","8"};
static char *enable_key[ ]=        { "disable","enable"};
static char  *chsel_key[ ]=        { "chsel_disable","chsel_enable"};
static char    *psn_key[ ]=        { "psn_disable","psn_enable"};
static char    *vtp_key[ ]=        { "vtp_disable","vtp_enable"};
static char *chseld_key[ ]=        { "chsel_disabled","chsel_enabled"};
static char   *psnd_key[ ]=        { "psn_disabled","psn_enabled"};
static char   *vtpd_key[ ]=        { "vtp_disabled","vtp_enabled"};

#define   NRATE_KEY sizeof(  rate_key)/sizeof( char *)
#define NENABLE_KEY sizeof(enable_key)/sizeof( char *)
#define  NCHSEL_KEY sizeof( chsel_key)/sizeof( char *)
#define    NPSN_KEY sizeof(   psn_key)/sizeof( char *)
#define    NVTP_KEY sizeof(   vtp_key)/sizeof( char *)
#define NCHSELD_KEY sizeof(chseld_key)/sizeof( char *)
#define   NPSND_KEY sizeof(  psnd_key)/sizeof( char *)
#define   NVTPD_KEY sizeof(  vtpd_key)/sizeof( char *)

char *m5trim();

int rdbe_chan_sel_en_dec(lcl,count,ptr)
  struct rdbe_chan_sel_en_cmd *lcl;
  int *count;
  char *ptr;
{
  int ierr, i, some;

  ierr=0;
  if(ptr == NULL) ptr="";

  switch (*count) {
    case 1:
      ierr=arg_key(ptr,rate_key,NRATE_KEY,&lcl->rate.rate,0,TRUE);
        m5state_init(&lcl->rate.state);
        if(ierr==0) {
          lcl->rate.state.known=1;
        } else {
          lcl->rate.state.error=1;
        }
      break;
    case 2:
      ierr=arg_key(ptr,enable_key,NENABLE_KEY,&lcl->chsel.chsel,1,TRUE);
        m5state_init(&lcl->chsel.state);
        if(ierr==0) {
          lcl->chsel.state.known=1;
        } else {
          lcl->chsel.state.error=1;
        }
      break;
    case 3:
      ierr=arg_key(ptr,enable_key,NENABLE_KEY,&lcl->psn.psn,1,TRUE);
        m5state_init(&lcl->psn.state);
        if(ierr==0) {
          lcl->psn.state.known=1;
        } else {
          lcl->psn.state.error=1;
        }
      break;
    case 4:
      ierr=arg_key(ptr,enable_key,NENABLE_KEY,&lcl->vtp.vtp,0,TRUE);
        m5state_init(&lcl->vtp.state);
        if(ierr==0) {
          lcl->vtp.state.known=1;
        } else {
          lcl->vtp.state.error=1;
        }
      break;
    default:
      *count=-1;
  }

  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void rdbe_chan_sel_en_enc(output,count,lclc)
  char *output;
  int *count;
  struct rdbe_chan_sel_en_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
    case 1:
      ivalue = lclc->rate.rate;
      if (ivalue >=0 && ivalue <NRATE_KEY)
        strcpy(output,rate_key[ivalue]);
      else
        strcpy(output,BAD_VALUE);
      break;
    case 2:
      ivalue = lclc->chsel.chsel;
      if (ivalue >=0 && ivalue <NENABLE_KEY)
        strcpy(output,enable_key[ivalue]);
      else
        strcpy(output,BAD_VALUE);
      break;
    case 3:
      ivalue = lclc->psn.psn;
      if (ivalue >=0 && ivalue <NENABLE_KEY)
        strcpy(output,enable_key[ivalue]);
      else
        strcpy(output,BAD_VALUE);
      break;
    case 4:
      ivalue = lclc->vtp.vtp;
      if (ivalue >=0 && ivalue <NENABLE_KEY)
        strcpy(output,enable_key[ivalue]);
      else
        strcpy(output,BAD_VALUE);
      break;
    default:
      *count=-1;
  }

  if(*count>0) *count++;
  return;
}
rdbe_chan_sel_en_2_rdbe(ptr,lcl)
  char *ptr;
  struct rdbe_chan_sel_en_cmd *lcl;
{
  strcpy(ptr,"dbe_chsel_en = ");

  if(lcl->rate.state.known && lcl->rate.rate >=0 && lcl->rate.rate <NRATE_KEY)
    strcat(ptr,rate_key[lcl->rate.rate]);
  strcat(ptr," : ");

  if(lcl->chsel.state.known && lcl->chsel.chsel >=0 && lcl->chsel.chsel <NENABLE_KEY)
    strcat(ptr,chsel_key[lcl->chsel.chsel]);
  strcat(ptr," : ");

  if(lcl->psn.state.known && lcl->psn.psn >=0 && lcl->psn.psn <NENABLE_KEY)
    strcat(ptr,psn_key[lcl->psn.psn]);
  strcat(ptr," : ");

  if(lcl->vtp.state.known && lcl->vtp.vtp >=0 && lcl->vtp.vtp <NENABLE_KEY)
    strcat(ptr,vtp_key[lcl->vtp.vtp]);

  strcat(ptr," ;\n");

  return;
}
int rdbe_2_rdbe_chan_sel_en(ptr_in,lclc,ip) /* return values:
                                            *  0 == no error
                                            *  0 != error
                                            */
  char *ptr_in;           /* input buffer to be parsed */

  struct rdbe_chan_sel_en_cmd *lclc;  /* result structure with parameters */
  int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL)
    ptr=strchr(ptr_in,'=');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  m5state_init(&lclc->rate.state);
  m5state_init(&lclc->chsel.state);
  m5state_init(&lclc->psn.state);
  m5state_init(&lclc->vtp.state);

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
          ierr=arg_key(ptr,rate_key,NRATE_KEY,&lclc->rate.rate,0,FALSE);
          if(ierr!=0 || 0==strcmp(ptr,"*")) {
            ierr=-500-count;
            goto error2;
          }
          lclc->rate.state.known=1;
          break;
        case 2:
          ierr=arg_key(ptr,chseld_key,NCHSELD_KEY,&lclc->chsel.chsel,0,FALSE);
          if(ierr!=0 || 0==strcmp(ptr,"*")) {
            ierr=-500-count;
            goto error2;
          }
          lclc->chsel.state.known=1;
          break;
        case 3:
          ierr=arg_key(ptr,psnd_key,NPSND_KEY,&lclc->psn.psn,0,FALSE);
          if(ierr!=0 || 0==strcmp(ptr,"*")) {
            ierr=-500-count;
            goto error2;
          }
          lclc->psn.state.known=1;
          break;
        case 4:
          ierr=arg_key(ptr,vtpd_key,NVTPD_KEY,&lclc->vtp.vtp,0,FALSE);
          if(ierr!=0 || 0==strcmp(ptr,"*")) {
            ierr=-500-count;
            goto error2;
          }
          lclc->vtp.state.known=1;
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
  memcpy(ip+3,"2l",2);
  return -1;
}
