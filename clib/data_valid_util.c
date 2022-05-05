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
/* S2 recorder data_valid buffer parsing utilities */

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

static char *dv_key[ ]={"off","on"};
static char *pb_key[ ]={"ignore","use"};

#define DV_KEY  sizeof(dv_key)/sizeof( char *)
#define PB_KEY  sizeof(pb_key)/sizeof( char *)

int data_valid_dec(lcl,count,ptr,kS2drive)
struct data_valid_cmd *lcl;
int *count;
char *ptr;
int kS2drive;
{
    int ierr, arg_key(), arg_int();
    int len;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,dv_key,DV_KEY,&lcl->user_dv,0,FALSE);
      break;      
    case 2:
      if(!kS2drive) {
	*count=-1;
	break;
      }
      ierr=arg_key(ptr,pb_key,PB_KEY,&lcl->pb_enable,1,TRUE);
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void data_valid_enc(output,count,lcl,kS2drive)
char *output;
int *count;
struct data_valid_cmd *lcl;
int kS2drive;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = lcl->user_dv;
    if (ivalue >=0 && ivalue <DV_KEY)
      strcpy(output,dv_key[ivalue]);
    else
      sprintf(output,"0x%x",ivalue);
    break;
  case 2:
    if(!kS2drive) {
      *count=-1;
      break;
    }
    ivalue = lcl->pb_enable;
    if (ivalue >=0 && ivalue <PB_KEY)
      strcpy(output,pb_key[ivalue]);
    else
      sprintf(output,"0x%x",ivalue);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}
