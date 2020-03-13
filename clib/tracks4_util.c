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
/* tracks4_util.c mark IV tracks parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int tracks4_dec(lcl,count,ptr)
struct form4_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(), code;
    static int itrk;

    ierr = 0;

    if(*count==1 && ptr != NULL && strcmp(ptr,"*")==0) {
      (*count)++;
      return ierr;
    } else if (*count==1) {
      lcl->enable[0] = 0;
      lcl->enable[1] = 0;
    }

    if(ptr == NULL) {
      *count=-1;
      return ierr;
    }

    if (strcmp(ptr,"v0")==0)
      lcl->enable[0] |= 0x00005555;
    else if (strcmp(ptr,"v1")==0)
      lcl->enable[0] |= 0x0000AAAA;
    else if (strcmp(ptr,"v2")==0)
      lcl->enable[0] |= 0x55550000;
    else if (strcmp(ptr,"v3")==0)
      lcl->enable[0] |= 0xAAAA0000;
    else if (strcmp(ptr,"v4")==0)
      lcl->enable[1] |= 0x00005555;
    else if (strcmp(ptr,"v5")==0)
      lcl->enable[1] |= 0x0000AAAA;
    else if (strcmp(ptr,"v6")==0)
      lcl->enable[1] |= 0x55550000;
    else if (strcmp(ptr,"v7")==0)
      lcl->enable[1] |= 0xAAAA0000;
    else if (strcmp(ptr,"m0")==0)
      lcl->enable[0] |= 0x00005554;
    else if (strcmp(ptr,"m1")==0)
      lcl->enable[0] |= 0x0000AAA8;
    else if (strcmp(ptr,"m2")==0)
      lcl->enable[0] |= 0x15550000;
    else if (strcmp(ptr,"m3")==0)
      lcl->enable[0] |= 0x2AAA0000;
    else if (strcmp(ptr,"m4")==0)
      lcl->enable[1] |= 0x00005554;
    else if (strcmp(ptr,"m5")==0)
      lcl->enable[1] |= 0x0000AAA8;
    else if (strcmp(ptr,"m6")==0)
      lcl->enable[1] |= 0x15550000;
    else if (strcmp(ptr,"m7")==0)
      lcl->enable[1] |= 0x2AAA0000;
    else if (strcmp(ptr,"s1")==0)
      lcl->enable[0]=~0;
    else if (strcmp(ptr,"s2")==0)
      lcl->enable[1]=~0;
    else if (strcmp(ptr,"all")==0) {
      lcl->enable[0]=~0;
      lcl->enable[1]=~0;
    } else {
      ierr=arg_int(ptr,&itrk,1,FALSE);
      if(ierr == 0 && (itrk < 2 || (itrk > 33 && itrk <102) || itrk > 133))
	ierr = -200;
      if(ierr == 0) {
	if (itrk <34)
	  lcl->enable[0]|= 1 << (itrk-2);
	else
	  lcl->enable[1]|= 1 << (itrk-102);
      }
    }

   if(*count>0)
     (*count)++;

   return ierr;
}

void tracks4_enc(output,count,lcl)
char *output;
int *count;
struct form4_cmd *lcl;
{
    int i;
    static unsigned int enable[2];

    if (*count == 1) {
      enable[0]=lcl->enable[0];
      enable[1]=lcl->enable[1];
    }

    output=output+strlen(output);

    for (i=0;i<32;i++)
      if (0 != (enable[0] & (1<<i))) {
	sprintf(output,"%d",i+2);
        enable[0] &= ~(1<<i);
	goto done;
      }
    for (i=0;i<32;i++)
      if (0 != (enable[1] & (1<<i))) {
	sprintf(output,"%d",i+102);
	enable[1] &= ~(1<<i);
	goto done;
      }
    
    *count = -1;
  done:
   if(*count>0)
     *count++;

   return;
}
