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
/* dbbcform buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *mode_key[ ]={"astro","geo","wastro","test","lba","astro2",
			  "astro3", "geo2"};
static char *pfb_key[ ]={"flex","full","full_auto", "spol"};
static char *test_key[ ]={"0","1","bin","tvg"};

#define NMODE_KEY sizeof(mode_key)/sizeof( char *)
#define NPFB_KEY sizeof(pfb_key)/sizeof( char *)
#define NTEST_KEY sizeof(test_key)/sizeof( char *)

int dbbcform_dec(lcl,count,ptr)
struct dbbcform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    int idefault;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
	if(DBBC_DDC == shm_addr->equip.rack_type ||
	   DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
	  ierr=arg_key(ptr,mode_key,NMODE_KEY,&lcl->mode,0,FALSE);
	  if(0 == ierr)
	    if(5==lcl->mode && shm_addr->dbbcddcv < 104)
	      ierr=-210;
	    else if(6==lcl->mode && shm_addr->dbbcddcvl[0] == ' ')
	      ierr=-220;
	    else if(NULL != index("ef",shm_addr->dbbcddcvl[0]) &&
		    3!=lcl->mode && 6!=lcl->mode)
	      ierr=-230;
	    else if(7==lcl->mode && shm_addr->dbbcddcv < 106)
	      ierr=-240;
	} else if(DBBC_PFB == shm_addr->equip.rack_type ||
		  DBBC_PFB_FILA10G == shm_addr->equip.rack_type) {
	  ierr=arg_key(ptr,pfb_key,NPFB_KEY,&lcl->mode,0,FALSE);
	}
        break;
      case 2:
	if(DBBC_DDC == shm_addr->equip.rack_type ||
	   DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
	  if(lcl->mode == 3)
	    ierr=arg_key(ptr,test_key,NTEST_KEY,&lcl->test,0,FALSE);
	  else {
	    lcl->test=-1;
	    ierr=0;
	  }
	} else
	  *count=-1;
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbcform_enc(output,count,lcl)
char *output;
int *count;
struct dbbcform_cmd *lcl;
{
    int ind, ivalue, whole, fract;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue = lcl->mode;
	if(DBBC_DDC == shm_addr->equip.rack_type ||
	   DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
	  if (ivalue >=0 && ivalue <NMODE_KEY)
	    strcpy(output,mode_key[ivalue]);
	  else
	    strcpy(output,BAD_VALUE);
	} else {
	  if (ivalue >=0 && ivalue <NPFB_KEY)
	    strcpy(output,pfb_key[ivalue]);
	  else
	    strcpy(output,BAD_VALUE);
	} 
        break;
      case 2:
	if(DBBC_DDC == shm_addr->equip.rack_type ||
	   DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
	  if(lcl->mode == 3) {
	    ivalue = lcl->test;
	    if (ivalue >=0 && ivalue <NTEST_KEY)
	      strcpy(output,test_key[ivalue]);
	  } else 
	    *count=-1;
	} else
	  *count=-1;
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbcform_2_dbbc(buff,lcl)
char *buff;
struct dbbcform_cmd *lcl;

{
  int ivalue;

  sprintf(buff,"dbbcform=");

  if(DBBC_DDC == shm_addr->equip.rack_type ||
     DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
    if(lcl->mode >= 0 && lcl->mode < NMODE_KEY)
      strcat(buff,mode_key[lcl->mode]);      

    if(lcl->mode == 3) {
      strcat(buff,",");
      if(lcl->test >= 0 && lcl->test < NTEST_KEY) 
	strcat(buff,test_key[lcl->test]);
    }
  } else {
    if(lcl->mode >= 0 && lcl->mode < NPFB_KEY)
      strcat(buff,pfb_key[lcl->mode]);      
  }

  return;
}

int dbbc_2_dbbcform(lclc,buff)
struct dbbcform_cmd *lclc;
char *buff;
{
  char *ptr, ch;
  int i, ierr;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");

  if(DBBC_DDC == shm_addr->equip.rack_type ||
     DBBC_DDC_FILA10G == shm_addr->equip.rack_type) {
    ierr=arg_key(ptr,mode_key,NMODE_KEY,&lclc->mode,-1,TRUE);
    if(ierr!=0)
      return -1;
    
    if(lclc->mode == 3) {
      ptr=strtok(NULL,",");
      ierr=arg_key(ptr,test_key,NTEST_KEY,&lclc->test,-1,TRUE);
      if(ierr!=0)
	return -1;
    }
  } else {
    ierr=arg_key(ptr,pfb_key,NPFB_KEY,&lclc->mode,-1,TRUE);
    if(ierr!=0)
      return -1;
  }

  return 0;
}
