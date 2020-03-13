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
/* mk6_scan_check_util.c - utilities for mark 5 scan_check command */

#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void mk6_scan_check_mon(output,count,lcl)
char *output;
int *count;
struct mk6_scan_check_mon *lcl;
{
  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    m5sprintf(output,"%d",&lcl->scan.scan,&lcl->scan.state);
    break;
  case 2:
    m5sprintf(output,"%s",lcl->label.label,&lcl->label.state);
    break;
  case 3:
      m5sprintf(output,"%s",lcl->type.type,&lcl->type.state);
    break;
  case 4:
    m5sprintf(output,"%d",&lcl->code.code,&lcl->code.state);
    break;
  case 5:
    m5time_encode(output,&lcl->start.start,&lcl->start.state);
    break;
  case 6:
    m5time_encode(output,&lcl->length.length,&lcl->length.state);
    break;
  case 7:
    m5sprintf(output,"%f",&lcl->total.total,&lcl->total.state);
    break;
  case 8:
    m5sprintf(output,"%Ld",&lcl->missing.missing,&lcl->missing.state);
    break;
  case 9:
    m5sprintf(output,"%s",lcl->error.error,&lcl->error.state);
    break;
  default:
    *count=-1;
  }
  
  return;
}

m5_2_mk6_scan_check(ptr_in,lclm,ip,what) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct mk6_scan_check_mon *lclm;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
     char *what;
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  m5state_init(&lclm->scan.state);
  m5state_init(&lclm->label.state);
  m5state_init(&lclm->start.state);
  m5state_init(&lclm->length.state);
  m5state_init(&lclm->missing.state);
  m5state_init(&lclm->type.state);
  m5state_init(&lclm->code.state);
  m5state_init(&lclm->total.state);
  m5state_init(&lclm->error.state);
 
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

    count=0;
    ptr_save=ptr;
    ptr=strsep(&ptr_save,":");
    while (ptr!=NULL) {
      switch (++count) {
      case 1:
	if(m5sscanf(ptr,"%d",&lclm->scan.scan, &lclm->scan.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 2:
	if(m5string_decode(ptr,&lclm->label.label,sizeof(lclm->label.label),
		  &lclm->label.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 3:
	if(m5string_decode(ptr,&lclm->type.type,sizeof(lclm->type.type),
			   &lclm->type.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	if(0==lclm->type.state.known)
	  goto done;
	break;
      case 4:
	if(m5sscanf(ptr,"%d",&lclm->code.code,&lclm->code.state)) {
	  ierr=-500-count;
	  goto error2;
	}
 	break;
      case 5:
	if(m5time_decode(ptr,&lclm->start.start, &lclm->start.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 6:
	if(m5time_decode(ptr,&lclm->length.length, &lclm->length.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 7:
	if(m5sscanf(ptr,"%f",&lclm->total.total, &lclm->total.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 8:
	if(m5sscanf(ptr,"%Ld",&lclm->missing.missing, &lclm->missing.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 9:
	if(m5string_decode(ptr,&lclm->error.error,sizeof(lclm->error.error),
			   &lclm->error.state)) {
	  ierr=-500-count;
	  goto error2;
	}
      default:
	goto done;
	break;
      }
      ptr=strsep(&ptr_save,":");
    }
  done:
    free(new_str);
  }
  return 0;

error2:
  free(new_str);

error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"3k",2);
  memcpy(ip+4,what,2);
  return -1;
}

