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
/* calrx buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/calrx_ds.h"

static char *type_key[ ]={ "fixed", "range" }; 

#define NTYPE_KEY sizeof(type_key)/sizeof( char *)

int calrx_dec(lcl,count,ptr)
struct calrx_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();
    int i;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      if(strlen(ptr)>sizeof(lcl->file))
	ierr=-200;
      else
	strcpy(lcl->file,ptr);
      break;
    case 2:
      ierr=arg_key(ptr,type_key,NTYPE_KEY,&lcl->type,0,FALSE);
      break;
    case 3:
      ierr=arg_dble(ptr,&lcl->lo[0],0.0,FALSE);
      break;
    case 4:
      ierr=arg_dble(ptr,&lcl->lo[1],-1.0,TRUE);
      break;
    default:
      *count=-1;
   }

   if(ierr!=0)
     ierr-=*count;
   if(*count>0)
     (*count)++;

   return ierr;
}

void calrx_enc(output,count,lcl)
char *output;
int *count;
struct calrx_cmd *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
	strcpy(output,lcl->file);
        break;
      case 2:
        ivalue = lcl->type;
        if (ivalue >=0 && ivalue <NTYPE_KEY)
          strcpy(output,type_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
	dble2str(output,lcl->lo[0],12,2);
	break;
      case 4:
	if(lcl->lo[1]>0.0)
	  dble2str(output,lcl->lo[1],12,2);
	break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}
