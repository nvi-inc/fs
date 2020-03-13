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
/* dbbc_pfbx buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void dbbc_pfbx_mon(output,count,lclm)
char *output;
int *count;
struct dbbc_pfbx_mon *lclm;
{
  int ind, ivalue, whole, fract;
  
  output=output+strlen(output);

  switch (*count) {
  case 17:
    if(lclm->overflow)
      strcpy(output,"OVERFLOW");
    break;
  case 16:
    if(shm_addr->dbbcpfbv<=15) {
      if(lclm->overflow)
	strcpy(output,"OVERFLOW");
      break;
    }
  default:
    if(shm_addr->dbbcpfbv<=15) {
      if(*count>16)
	*count=-1;
      else
	sprintf(output,"%d.%03d",lclm->counts[*count-1]/1000,
		lclm->counts[*count-1]%1000);
    } else
      if(*count>17)
	*count=-1;
      else
	sprintf(output,"%d",lclm->counts[*count-1]);
  }
  
  if(*count>0) *count++;
  return;
}

int dbbc_2_dbbc_pfbx(lclm,buff)
struct dbbc_pfbx_mon *lclm;
char *buff;
{
  int k;
  char *sptr;
  double dvalue;

  lclm->overflow=NULL!=strstr(buff,"OVERFLOW"); /* overflowed */

  sptr=strtok(buff,"=");
  if(NULL==sptr)
    return -1;

  if(shm_addr->dbbcpfbv<=15)
    for(k=0;k<15;k++) {
      sptr=strtok(NULL," ,");
      if(NULL==sptr || 1!=sscanf(sptr,"%lf",&dvalue))
	return -2;
      lclm->counts[k]=dvalue*1000+.5;
    }
  else
    for(k=0;k<16;k++) {
      sptr=strtok(NULL," ;");
      if(NULL==sptr || 1!=sscanf(sptr,"%d",&lclm->counts[k]))
	return -2;
    }
  
  return 0;
}
