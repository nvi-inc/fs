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
/* mark IV pcalportparsing utilities */

#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"
                                             /* parameter keywords */
static char *key_vc1[ ]={ "1" , "2" , "3" , "4" ,  "9" , "10" , "11", "12"};
static char *key_vc2[ ]={ "5" , "6" , "7" , "8" , "13" , "14" , "15", "16"};

                                          /* number of elem. keyword arrays */
#define NKEY_VC1 sizeof(key_vc1)/sizeof( char *)
#define NKEY_VC2 sizeof(key_vc2)/sizeof( char *)

int pcalports_dec(lcl,count,ptr)
struct pcalports_cmd *lcl;
int *count;
char *ptr;
{
  int ierr, ind, arg_key(),len,i,j,ivalue,ish;
  unsigned mode, datain;
  int ioff, ifm;

  ierr=0;
  if(ptr == NULL) ptr="";

  switch (*count) {
  case 1:
    ierr=arg_key(ptr,key_vc1,NKEY_VC1,&lcl->bbc[0],0,FALSE);
    break;
  case 2:
    ierr=arg_key(ptr,key_vc2,NKEY_VC2,&lcl->bbc[1],0,FALSE);
    break;
  default:
    *count=-1;
  }
  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void pcalports_enc(output,count,lcl)
char *output;
int *count;
struct pcalports_cmd *lcl;
{
    int ind, ivalue, iokay, i, j;
    int codes, clock;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      ivalue=lcl->bbc[0];
      if(ivalue>=0 && ivalue <NKEY_VC1)
	strcpy(output,key_vc1[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    case 2:
      ivalue=lcl->bbc[1];
      if(ivalue>=0 && ivalue <NKEY_VC2)
	strcpy(output,key_vc2[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    default:
      *count=-1;
      break;
   }
   if(*count>0) *count++;
   return;
}

void pcalportsPCAma(buff, lcl)
char *buff;
struct pcalports_cmd *lcl;
{
  buff+=4;

  sprintf(buff,"/PCA %s %s",key_vc1[lcl->bbc[0]],key_vc2[lcl->bbc[1]]);
}
