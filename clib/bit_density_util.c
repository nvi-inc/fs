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
/* bit_density parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int bit_density_dec(lcl,count,ptr)
int *lcl;
int *count;
char *ptr;
{
    int ierr, arg_int();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_int(ptr,lcl,0,FALSE);
      if(ierr==0 && lcl <=0 )
	ierr = -200;
      break;
    default:
      *count=-1;
      break;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void bit_density_enc(output,count,lcl)
char *output;
int *count;
int *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        if(*lcl > 0)
           sprintf(output,"%d",*lcl);
        else
          strcpy(output,"UNDEFINED");
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}
