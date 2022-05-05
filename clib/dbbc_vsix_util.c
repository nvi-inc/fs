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
/* dbbc_vsix buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int dbbc_vsix_dec(lcl,count,ptr)
struct dbbc_vsix_cmd *lcl;
int *count;
char *ptr;
{
  int ierr, i, ichan;

    ierr=0;

    if(1==*count)
      for (i=0;i<16;i++)
	lcl->core[i]=0;

    if(17==*count && ptr!=NULL) {
      ierr=-300;
      return ierr;
    }
    if(ptr == NULL) {
      *count=-1;
      return 0;
    }
    switch (ptr[0]) {
    case 0:
      break;
    case 'a':
    case 'A':
      if(1!=sscanf(ptr+1,"%d",&ichan))
	ierr=-200;
      else if(ichan<0||ichan>=16*shm_addr->dbbc_como_cores[0])
	ierr=-220;
      lcl->core[*count-1]=1+ichan/16;
      lcl->chan[*count-1]=ichan%16;
      break;
    case 'b':
    case 'B':
      if(1!=sscanf(ptr+1,"%d",&ichan))
	ierr=-200;
      else if(ichan<0||ichan>=16*shm_addr->dbbc_como_cores[1])
	ierr=-220;
      lcl->core[*count-1]=shm_addr->dbbc_como_cores[0]+
	1+ichan/16;
      lcl->chan[*count-1]=ichan%16;
      break;
    case 'c':
    case 'C':
      if(1!=sscanf(ptr+1,"%d",&ichan))
	ierr=-200;
      else if(ichan<0||ichan>=16*shm_addr->dbbc_como_cores[2])
	ierr=-220;
      lcl->core[*count-1]=shm_addr->dbbc_como_cores[0]+
	shm_addr->dbbc_como_cores[1]
	+1+ichan/16;
      lcl->chan[*count-1]=ichan%16;
      break;
    case 'd':
    case 'D':
      if(1!=sscanf(ptr+1,"%d",&ichan))
	ierr=-200;
      else if(ichan<0||ichan>=16*shm_addr->dbbc_como_cores[3])
	ierr=-220;
      lcl->core[*count-1]=shm_addr->dbbc_como_cores[0]+
	shm_addr->dbbc_como_cores[1]
	+shm_addr->dbbc_como_cores[2]+
	1+ichan/16;
      lcl->chan[*count-1]=ichan%16;
      break;
    default:
      ierr=-220;
      break;
    }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbc_vsix_enc(output,count,lcl)
char *output;
int *count;
struct dbbc_vsix_cmd *lcl;
{
  int core,chan,ifc,i;
  static char letters[ ]=" abcd";
 
  output=output+strlen(output);

  if(*count<17) {
    core=lcl->core[*count-1];
    ifc=1;
    if(core>0) {
      for(i=1;i<=shm_addr->dbbc_cond_mods &&
	    core>shm_addr->dbbc_como_cores[i-1];i++) {
	ifc+=1;
	core-=shm_addr->dbbc_como_cores[i-1];
      }
      chan=lcl->chan[*count-1]+(core-1)*16;
      sprintf(output,"%c%02d",letters[ifc],chan);
    }
  } else
    *count=-1;
  
  if(*count>0) *count++;
  return;
}

void dbbc_vsix_2_dbbc(buff,lcl,itask,core)
char *buff;
struct dbbc_vsix_cmd *lcl;
int itask;
int core;
{
  int i;

  sprintf(buff,"dbbctrk=%d,%d",core,itask+1);

  for(i=0;i<16;i++) {
    strcat(buff,",");
    buff+=strlen(buff);
    if(core!=lcl->core[i])
      sprintf(buff,"v%d-%d",itask+1,i);
    else
      sprintf(buff,"p-%d",lcl->chan[i]);
  }

  return;
}

int dbbc_2_dbbc_vsix(lclc,buff)
struct dbbc_vsix_cmd *lclc;
char *buff;
{
  /* not fully coded or debug, device does not return monitor response 
  char *ptr, ch;
  int i, ierr;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");
  if(1!=sscanf(ptr,"%d",&core) || core <0 || core > 4)
    return -1;

  for(i=0;i<16,i++) {
    ptr=strtok(NULL,",");
    if('v'==ptr[0])
      continue;
    else if('p'==ptr[0]) {
      if(1!=sscanf(ptr+2,"%d",&chan) || chan <0 || chan > 15)
	return -1;
      else {
	lcl->core[i]=core;
	lcl->chan[i]=chan;
      }
    }
  */
    return 0;
}
