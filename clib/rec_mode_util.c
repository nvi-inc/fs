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
/* S2 recorder st buffer parsing utilities */

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

static char *roll_key[ ]={"off","on"};

#define ROLL_KEY  sizeof(roll_key)/sizeof( char *)

int rec_mode_dec(lcl,count,ptr)
struct rec_mode_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      if(strlen(ptr) > RCL_MAXSTRLEN_MODE-1)
	ierr = -200;
      else if(strlen(ptr) <= 0)
	ierr = -100;
      else
	strcpy(lcl->mode,ptr);
      break;      
    case 2:
      ierr=arg_int(ptr,&lcl->group,0,FALSE);
      break;
    case 3:
      ierr=arg_key(ptr,roll_key,ROLL_KEY,&lcl->roll,1,TRUE);
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void rec_mode_enc(output,count,lcl)
char *output;
int *count;
struct rec_mode_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    strcpy(output,lcl->mode);
    break;
  case 2:
    ivalue = lcl->group;
    sprintf(output,"%d",ivalue);
    break;
  case 3:
    ivalue = lcl->roll;
    if (ivalue >=0 && ivalue <ROLL_KEY)
      strcpy(output,roll_key[ivalue]);
    break;
  case 4:
    ivalue = lcl->num_groups;
    if(ivalue > 0)
      sprintf(output,"%d",ivalue);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}

