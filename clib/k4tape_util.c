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
/* k4 recorder tape buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/k4tape_ds.h"

static char device[]={"r1"};           /* device menemonics */

static char *state_key[ ]={"reset"};
static char *state1_key[ ]={"off","on"};

#define STATE_KEY  sizeof(state_key)/sizeof( char *)
#define STATE1_KEY  sizeof(state1_key)/sizeof( char *)

#define MAX_BUF 512

int k4tape_dec(reset,count,ptr)
int *reset;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,state_key,STATE_KEY,reset,0,FALSE);
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4tape_mon(output,count,lcl)
char *output;
int *count;
struct k4tape_mon *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    strcpy(output,lcl->pos);
    break;
  case 2:
    ivalue = lcl->drum;
    if (ivalue >=0 && ivalue <STATE1_KEY)
      strcpy(output,state1_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 3:
    ivalue = lcl->synch;
    if (ivalue >=0 && ivalue <STATE1_KEY)
      strcpy(output,state1_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 4:
    strcpy(output,lcl->lost);
    break;
  case 5:
    sprintf(output,"0x%x",lcl->stat1);
    break;
  case 6:
    sprintf(output,"0x%x",lcl->stat2);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}

k4tape_req_q(ip)
int ip[5];
{
  if(shm_addr->k4tape_sqn[0]==0)
    ib_req7(ip,device,20,"SQN?");
  ib_req7(ip,device,20,"SQN?");
  ib_req7(ip,device,20,"DRM?");
  ib_req7(ip,device,20,"SYT?");
  ib_req7(ip,device,20,"SYN?");
  ib_req8(ip,device,10,"STAT?");
}

k4tape_req_c(ip,reset)
int ip[5];
int *reset;
{
  ib_req2(ip,device,"REC=0,50");

}

k4tape_res_q(lcl,ip)
struct k4tape_mon *lcl;
int ip[5];
{
  unsigned char buffer[MAX_BUF];
  int max;

  if(shm_addr->k4tape_sqn[0]==0) {
    max=sizeof(buffer);
    ib_res_ascii(buffer,&max,ip);
    if(max < 0)
      return -1;
  }
  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  if(1!=sscanf(buffer,"SQN=%8s",lcl->pos))
    if(strcmp(buffer,"NULL")==0)
      strcpy(lcl->pos,"NULL");
  
  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  if(strcmp(buffer,"DRM=ON")==0)
    lcl->drum=1;
  else if(strcmp(buffer,"DRM=OFF")==0)
    lcl->drum=0;
  else
    lcl->drum=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  if(strcmp(buffer,"SYT=ON")==0)
    lcl->synch=1;
  else if(strcmp(buffer,"SYT=OFF")==0)
    lcl->synch=0;
  else
    lcl->synch=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  sscanf(buffer,"SYN=%2s",lcl->lost);

  max=sizeof(buffer);
  ib_res_bin(buffer,&max,ip);
  if(max < 0)
    return -1;
  lcl->stat1=buffer[0];
  lcl->stat2=buffer[1];
}
