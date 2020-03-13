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
/* trkfrm_util.c vlba trkfrm parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

char *code2bs();
int bs2code();

int trkfrm_dec(lcl,count,ptr)
struct vform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), code, i;
    static int itrk;
    static int kfirst = TRUE;
    static char *type;

    ierr=0;

    if (kfirst) {
      if(shm_addr->equip.rack == VLBA) {
	if(shm_addr->equip.rack_type == VLBA)
	  type="vlba";
	else if(shm_addr->equip.rack_type == VLBAG)
	  type="vlbag";
	else
	  ierr=-300;
      } else
	type="vlbag";  /* only VLBAG were every modified to include other formatters: VLBA4 or VLBA45 */
      kfirst=FALSE;
    }  
      
    if(ptr == NULL) {
      if(*count%2 == 0)
	ierr = -304;
      *count=-1;
      return ierr;
    }

    switch (*count%2) {
    case 1:
      if(lcl->last == 1) {
	for(i=0;i<32;i++)
	  lcl->codes[i]=-1;
	lcl->last=0;
      }
      ierr=arg_int(ptr,&itrk,1,FALSE);
      if(ierr == 0 && (itrk < 2 || itrk > 33))
	ierr = -200;
      break;
    case 0:
      code=bs2code(ptr,type);
      if(code < -1)
	ierr=-299+code;
      else {
	if(itrk%2==0)
	  lcl->codes[15+(itrk/2)]=code;
	else
	  lcl->codes[(itrk-3)/2]=code;
      }
      break;
    default:
      *count=-1;
    }

   if(*count>0)
     (*count)++;

   return ierr;
}

void trkfrm_enc(output,count,lcl)
char *output;
int *count;
struct vform_cmd *lcl;
{
    int i;
    static int kfirst = TRUE;
    static char *type;
    static int itrk, ilast;

    if (kfirst) {
      if(shm_addr->equip.rack == VLBA) {
	if(shm_addr->equip.rack_type == VLBA)
	  type="vlba";
	else if(shm_addr->equip.rack_type == VLBAG)
	  type="vlbag";
	else
	  type="";
      } else
	type="vlbag";  /* only VLBAG were every modified to include other formatters: VLBA4 or VLBA45 */
      kfirst=FALSE;
    }  

    if(*count==1)
      ilast = 1;

    if (ilast >= 33) {
      *count= -1;
      return;
    }

    output=output+strlen(output);
    
    for(i=ilast+1;i<34;i++){
      if (i%2==0)
	 itrk=15+(i/2);
      else
	itrk=(i-3)/2;
      if (lcl->codes[itrk]!=-1){
	ilast=i;
	sprintf(output,"%2d,%4s",i,code2bs(lcl->codes[itrk],type));
	goto done;
      }
    }
    if(ilast==1)
      strcpy(output,"DISABLED");

    *count=-1;
    return;

  done:
   if(*count>0)
     *count++;

   return;
}
