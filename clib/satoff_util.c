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
/* satoff buffer parsing utilities */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *key_mode[ ]={ "track"  , "radc"  , "azel"};
static char *key_wrap[ ]={ "neutral"  , "ccw"  , "cw"};
static char *key_hold[ ]={ "track"  , "hold"};

#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_WRAP sizeof(key_wrap)/sizeof( char *)
#define NKEY_HOLD sizeof(key_hold)/sizeof( char *)

int satoff_dec(lcl,count,ptr)
struct satoff_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k;
    double freq;

    ierr=0;
    if(ptr==NULL) {
      ptr="";
    }

    switch (*count) {
    case 1:
	ierr=arg_dble(ptr,&lcl->seconds,0.0,FALSE);
	break;
    case 2:
	ierr=arg_dble(ptr,&lcl->cross,0.0,FALSE);
	lcl->cross*=DEG2RAD;
	break;
    case 3:
      ierr=arg_key(ptr,key_hold,NKEY_HOLD,&lcl->hold,0,TRUE);
      break;
    default:
      *count=-1;
    }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void satoff_enc(output,count,lcl)
char *output;
int *count;
struct satoff_cmd *lcl;
{
  int ivalue,i,j,k,lenstart,limit;
  static int inext;

  output=output+strlen(output);

    switch (*count) {
    case 1:
      sprintf(output+strlen(output),"%.3lf",lcl->seconds);
      break;
    case 2:
      sprintf(output+strlen(output),"%.3lf",lcl->cross*RAD2DEG);
      break;
    case 3:
      ivalue=lcl->hold;
      if(ivalue>=0 && ivalue <NKEY_MODE)
	strcpy(output,key_hold[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    default:
      *count=-1;
    }

    if(*count>0) *count++;
    return;
}
