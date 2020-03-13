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
/* lba das mon buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

/* function prototypes */
int arg_key();

/* global variables/definitions */

static char *sb_key[ ]={"usb","lsb"};

#define NSB_KEY sizeof(sb_key)/sizeof( char *)

int lba_mon_dec(lcl,count,ptr)
  struct ifp *lcl;
  int *count;
  char *ptr;
{
    int ierr;

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
          ierr=arg_key(ptr,sb_key,NSB_KEY,&lcl->bs.monitor.setting,_LSB,TRUE);
        break;
      case 2:
          ierr=arg_key(ptr,sb_key,NSB_KEY,&lcl->ft.monitor.setting,_USB,TRUE);
        break;
      case 3:
          ierr=arg_key(ptr,sb_key,NSB_KEY,&lcl->ft.digout.setting,_USB,TRUE);
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void lba_mon_enc(output,count,lcl)
char *output;
int *count;
struct ifp *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue = lcl->bs.monitor.setting;
        if (ivalue >=0 && ivalue <NSB_KEY)
          strcpy(output,sb_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
        ivalue = lcl->ft.monitor.setting;
        if (ivalue >=0 && ivalue <NSB_KEY)
          strcpy(output,sb_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
        ivalue = lcl->ft.digout.setting;
        if (ivalue >=0 && ivalue <NSB_KEY)
          strcpy(output,sb_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}
