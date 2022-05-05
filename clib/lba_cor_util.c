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
/* lba das cor buffer parsing utilities */

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
int arg_int();

/* global variables/definitions */
static char *cr_key[ ]={"at","mb"};
static char *op_key[ ]={"bsu","bsl","ftu","ftl","32","64","usb","lsb"};

#define NCR_KEY sizeof(cr_key)/sizeof( char *)
#define NOP_KEY sizeof(op_key)/sizeof( char *)

int lba_cor_dec(lcl,count,ptr)
  struct ifp *lcl;
  int *count;
  char *ptr;
{
    int ierr;

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
          ierr=arg_key(ptr,cr_key,NCR_KEY,&lcl->corr_type,_4_LVL,TRUE);
        break;
      case 2:
          ierr=arg_key(ptr,op_key,NOP_KEY,&lcl->corr_source[0],(lcl->corr_type == _4_LVL)?_A_U:_A_L,TRUE);
        break;
      case 3:
          ierr=arg_key(ptr,op_key,NOP_KEY,&lcl->corr_source[1],_A_U,TRUE);
        break;
      case 4:
          ierr=arg_int(ptr,&lcl->at_clock_delay,0,TRUE);
          if (lcl->at_clock_delay < 0 || lcl->at_clock_delay > 3)
             ierr=-200;
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void lba_cor_enc(output,count,lcl)
char *output;
int *count;
struct ifp *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue = lcl->corr_type;
        if (ivalue >=0 && ivalue <NCR_KEY)
          strcpy(output,cr_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
      case 3:
        ivalue = lcl->corr_source[*count-2];
        if (ivalue >=0 && ivalue <NOP_KEY)
          strcpy(output,op_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 4:
        ivalue = lcl->at_clock_delay;
        if (ivalue >=0 && ivalue <3)
          sprintf(output,"%d",ivalue);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}
