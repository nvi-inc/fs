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
/* mcb command buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/mcb_ds.h"

int mcb_dec(lcl,count,ptr)
struct mcb_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
        if(strlen(ptr)==0)
          memcpy(lcl->device,"\0",2);
        else
          memcpy(lcl->device,ptr,2);
        break;
      case 2:
        if(strlen(ptr)==0)
          ierr=-100;
        else
          if(1!=sscanf(ptr,"%x",&lcl->addr))
            ierr=-200;
        break;
      case 3:
        if(strlen(ptr)==0)
          lcl->cmd=0;
        else {
          lcl->cmd=1;
          if(1!=sscanf(ptr,"%x",&lcl->data))
            ierr=-200;
        }
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void mcb_mon(output,count,lcl)
char *output;
int *count;
struct mcb_mon *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%04.4x",0xFFFF & lcl->data);
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}
