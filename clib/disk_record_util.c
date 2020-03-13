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
/* vlba disk_record commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *record_key[ ]=         { "off", "on" }; 
static char *record_display_key[ ]={ "off", "on", ""}; 

#define NRECORD_KEY sizeof(record_key)/sizeof( char *)
#define NRECORD_DISPLAY_KEY sizeof(record_display_key)/sizeof( char *)

char *m5trim();

int disk_record_dec(lcl,count,ptr)
struct disk_record_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();
    
    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,record_key,NRECORD_KEY,&lcl->record.record,0,FALSE);
	if(ierr==0) {
	  m5state_init(&lcl->record.state);
	  lcl->record.state.known=1;
	} else {
	  m5state_init(&lcl->record.state);
	  lcl->record.state.error=1;
	} 
        break;
      case 2:
	if(strlen(ptr) > sizeof(lcl->label.label)-1 ||
	   strlen(ptr) > 63 ) /* protect against old versions of Mark5A */ 
	  ierr=-200;
	else if(strlen(ptr) == 0 &&
		((strlen(shm_addr->scan_name.name)+
		  strlen(shm_addr->scan_name.session)+
		  strlen(shm_addr->scan_name.station)+2)>
		 sizeof(lcl->label.label)-1||
		 (strlen(shm_addr->scan_name.name)+
		  strlen(shm_addr->scan_name.session)+
		  strlen(shm_addr->scan_name.station)+2)>63))
	  ierr=-300;
	else if(strlen(ptr) == 0) {
	  strcpy(lcl->label.label,shm_addr->scan_name.session);
	  strcat(lcl->label.label,"_");
	  strcat(lcl->label.label,shm_addr->scan_name.station);
	  strcat(lcl->label.label,"_");
	  strcat(lcl->label.label,shm_addr->scan_name.name);
	} else 
	  strcpy(lcl->label.label,ptr);
	if(ierr==0) {
	  m5state_init(&lcl->label.state);
	  lcl->label.state.known=1;
	} else {
	  m5state_init(&lcl->label.state);
	  lcl->label.state.error=1;
	} 
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void disk_record_enc(output,count,lclc,lclm)
char *output;
int *count;
struct disk_record_cmd *lclc;
struct disk_record_mon *lclm;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      if(lclc->record.record!=NRECORD_DISPLAY_KEY)
	m5key_encode(output,record_display_key,NRECORD_DISPLAY_KEY,
		     lclc->record.record,&lclc->record.state);
      else
	m5sprintf(output,"%s",lclm->status.status,&lclm->status.state);
      break;
    case 2:
      m5sprintf(output,"%s",lclc->label.label,&lclc->label.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}
void disk_record_mon(output,count,lcl)
char *output;
int *count;
struct disk_record_mon *lcl;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5sprintf(output,"%d",&lcl->scan.scan,&lcl->scan.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}

disk_record_2_m5(ptr,lcl)
char *ptr;
struct disk_record_cmd *lcl;
{
  strcpy(ptr,"record = ");

  if(lcl->record.record==1)
    strcat(ptr,record_key[1]);
  else
    strcat(ptr,record_key[0]);
  strcat(ptr," : ");

  strcat(ptr,lcl->label.label);
  if(strlen(lcl->label.label)!=0)
    strcat(ptr," ; \n");
  else
    strcat(ptr,"; \n ");

  return;
}
m5_2_disk_record(ptr_in,lclc,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct disk_record_cmd *lclc;  /* result structure with parameters */
     struct disk_record_mon *lclm;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss, i;
  char string[33];

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }
  /* no monitor response */
  m5state_init(&lclc->record.state);
  lclc->record.record=NRECORD_DISPLAY_KEY;
  lclc->record.state.known=1;

  m5state_init(&lclc->label.state);
  m5state_init(&lclm->status.state);
  m5state_init(&lclm->scan.state);

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
	if(m5string_decode(ptr,lclm->status.status,sizeof(lclm->status.status),
			   &lclm->status.state)) {
	  ierr=-501;
	  goto error2;
	}
	break;
      case 2:
	if(m5sscanf(ptr,"%d",&lclm->scan.scan,&lclm->scan.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(m5string_decode(ptr,lclc->label.label,sizeof(lclc->label.label),
			   &lclc->label.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
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
  memcpy(ip+3,"5r",2);
  return -1;
}
