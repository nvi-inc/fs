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
/* S2 recorder tape buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl.h"

int s2tape_dec(position,count,ptr)
int position[8];
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;
    static int found;

    if(*count==1)
      found=0;

    ierr=0;
    if(*count == -1 || ptr == NULL) {
      if(found!=1&&found!=0xff)
	return -301;
      *count=-1;
      return ierr;
    } else if (*count > 8)
      return -301;

    position+=*count-1;

    if (strcmp(ptr,"unk")==0)
	*position=RCL_POS_UNKNOWN;
    else if (strcmp(ptr,"uns")==0)
	*position=RCL_POS_UNSEL;
    else {
      ierr=arg_int(ptr,position,0,FALSE);
    }

    if(ierr==0 && *count >0)
      found|=1 <<(*count-1);

    if(ierr!=0)
      ierr-=*count;
    if(*count>0)
      (*count)++;
    return ierr;
}
