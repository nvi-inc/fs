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
/* dbbc3 iftpx buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void dbbc3_iftpx_mon(output,count,lcl)
char *output;
int *count;
struct dbbc3_iftpx_mon *lcl;
{
    int ind;
    
    output=output+strlen(output);

    switch (*count) {
      case 1:
	sprintf(output,"%u",lcl->tp);
	break;
      case 2:
	sprintf(output,"%u",lcl->off);
	break;
      case 3:
	sprintf(output,"%u",lcl->on);
	break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

int dbbc3_2_iftpx(lclm,buff)
struct dbbc3_iftpx_mon *lclm;
char *buff;
{
  char *ptr, ch;
  int i, ierr, idum;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",&lclm->tp,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",&lclm->off,&ch))
    return -1;

  ptr=strtok(NULL,",;");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",&lclm->on,&ch))
    return -1;

  return 0;
}
