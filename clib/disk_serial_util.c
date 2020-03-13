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
/* disk_serial_util.c - utilities for mark 5 disk_serial command */

#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"

char *m5trim();

void disk_serial_mon(output,count,lcl)
char *output;
int *count;
struct disk_serial_mon *lcl;
{

    output=output+strlen(output);

    if(*count <= lcl->count) {
      m5sprintf(output,"%s",&lcl->serial[*count-1].serial,
		&lcl->serial[*count-1].state);
    } else
      *count=-1;
    
   if(*count > 0) *count++;
   return;
}

m5_2_disk_serial(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct disk_serial_mon *lclm; /* result structure with serial numbers
				    * blank means empty response
				    * null means no response
				    */
     int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  count=0;

  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logit(NULL,errno,"un");
      ierr=-902;
      goto error;
    }

    ptr2=strchr(ptr,';'); /* terminate the string at the ; */
    if(ptr2!=NULL)
      *ptr2=0;

    ptr_save=ptr;
    ptr=strsep(&ptr_save,":");
    while (ptr!=NULL && count<MK5_DISK_SERIAL_MAX) {
      if(0!=m5string_decode(ptr,&lclm->serial[count].serial,
			 sizeof(lclm->serial[count].serial),
			 &lclm->serial[count].state)) {
	ierr=-501;
	goto error2;
      }
      count++;
      ptr=strsep(&ptr_save,":");
    }
    free(new_str);
    if(ptr!=NULL && count >= MK5_DISK_SERIAL_MAX) {
      ierr=-903;
      goto error;
    }
  }

  lclm->count=count;
  return 0;

error2:
  free(new_str);
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"5s",2);
  return -1;

}

