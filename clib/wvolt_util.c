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
/* ifd wvolt buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/macro.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int wvolt_dec(lcl,count,ptr,indx)
struct wvolt_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_float();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      if(0==strcmp(ptr,"*") && !lcl->set[0])
	ierr=-300;
      else {
	ierr=arg_float(ptr,&lcl->volts[0],0,FALSE);
	if(ierr==0)
	  lcl->set[0]=TRUE;
      }
      break;
    case 2:
      if(shm_addr->equip.drive[indx] == VLBA4||
	 (shm_addr->equip.drive[indx]==VLBA &&
	  shm_addr->equip.drive_type[indx]==VLBAB)) {
	if(0==strcmp(ptr,"*") && !lcl->set[1])
	  ierr=-300;
	else {
	  ierr=arg_float(ptr,&lcl->volts[1],0,FALSE);
	  if(ierr==0)
	    lcl->set[1]=TRUE;
	}
	break;
      }
    default:
      *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void wvolt_enc(output,count,lcl,indx)
char *output;
int *count;
struct wvolt_cmd *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      if(lcl->set[0])
	flt2str(output,lcl->volts[0],32,1);
      break;
    case 2:
      if(shm_addr->equip.drive[indx] == VLBA4||
	 (shm_addr->equip.drive[indx]==VLBA &&
	  shm_addr->equip.drive_type[indx]==VLBAB)) {
	if(lcl->set[1])
	  flt2str(output,lcl->volts[1],32,1);
	break;
      }
    default:
      *count=-1;
    }
    if(*count>0) *count++;
    return;
}
void wvoltD2mc(data,lcl)
unsigned *data;
struct wvolt_cmd *lcl;
{
  int volt;

  volt = (int)((lcl->volts[1]/2)*1000);
  *data= bits16on(14) & volt;

  return;
}

void wvoltD3mc(data,lcl)
unsigned *data;
struct wvolt_cmd *lcl;
{
  int volt;

  volt = (int)((lcl->volts[0]/2)*1000);
  *data= bits16on(14) & volt;

  return;
}

void mcD2wvolt(lcl, data)
struct wvolt_cmd *lcl;
unsigned data;
{
  double volts;

  volts= bits16on(14) & data;

  lcl->volts[1]=(volts/1000.)*2.0;
  lcl->set[1]=TRUE;

  return;
}

void mcD3wvolt(lcl, data)
struct wvolt_cmd *lcl;
unsigned data;
{
  double volts;

  volts= bits16on(14) & data;

  lcl->volts[0]=(volts/1000.)*2.0;
  lcl->set[0]=TRUE;

  return;
}
