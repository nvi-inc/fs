/* mk6_record commmand buffer parsing utilities */

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

static char *action_key[ ]=         { "off", "on" }; 
static char *status_key[ ]={ "off", "pending", "recording","flushing"}; 

#define NACTION_KEY sizeof(action_key)/sizeof( char *)
#define NSTATUS_KEY sizeof(status_key)/sizeof( char *)

char *m5trim();

int mk6_record_dec(lcl,count,ptr)
struct mk6_record_cmd *lcl;
int *count;
char *ptr;
{
  int ierr, i, arg_key();
  int dum;
  double ddum;

  ierr=0;
  if(ptr == NULL) ptr="";
  
  switch (*count) {
  case 1:
    ierr=arg_key(ptr,action_key,NACTION_KEY,&lcl->action.action,0,FALSE);
    if(ierr==-200 &&
       5==sscanf(ptr,"%dy%dd%dh%dm%lfs",&dum,&dum,&dum,&dum,&ddum) &&
       strlen(ptr) <= sizeof(lcl->action.action)-1)
      ierr=0;
    if(ierr==0) {
      strcpy(lcl->action.action,ptr);
      m5state_init(&lcl->action.state);
      lcl->action.state.known=1;
    } else {
      m5state_init(&lcl->action.state);
      lcl->action.state.error=1;
    } 
    break;
  case 2:
    ierr=arg_int(ptr,&lcl->duration.duration,0,FALSE);
    if(lcl->duration.duration <= 0)
      ierr=-200;
    if(ierr==0) {
      m5state_init(&lcl->duration.state);
      lcl->duration.state.known=1;
    } else {
      m5state_init(&lcl->duration.state);
      lcl->duration.state.error=1;
    } 
    break;
  case 3:
    ierr=arg_int(ptr,&lcl->size.size,0,FALSE);
    if(lcl->size.size <= 0)
      ierr=-200;
    if(ierr==0) {
      m5state_init(&lcl->size.state);
      lcl->size.state.known=1;
    } else {
      m5state_init(&lcl->size.state);
      lcl->size.state.error=1;
    } 
    break;
  case 4:
    if(strlen(ptr)>32)
      ierr=-200;
    if(ierr==0) {
      m5state_init(&lcl->scan.state);
      lcl->scan.state.known=1;
    } else {
      m5state_init(&lcl->scan.state);
      lcl->scan.state.error=1;
    } 
    break;
  case 5:
    if(strlen(ptr)>8)
      ierr=-200;
    if(ierr==0) {
      m5state_init(&lcl->experiment.state);
      lcl->experiment.state.known=1;
    } else {
      m5state_init(&lcl->experiment.state);
      lcl->experiment.state.error=1;
    } 
    break;
  case 6:
    if(strlen(ptr)>8)
      ierr=-200;
    if(ierr==0) {
      m5state_init(&lcl->station.state);
      lcl->station.state.known=1;
    } else {
      m5state_init(&lcl->station.state);
      lcl->station.state.error=1;
    } 
    break;
  default:
    *count=-1;
  }

  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void mk6_record_enc(output,count,lclc)
char *output;
int *count;
struct mk6_record_cmd *lclc;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5sprintf(output,"%s",lclc->action.action,&lclc->action.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclc->duration.duration,&lclc->duration.state);
      break;
    case 3:
      m5sprintf(output,"%d",&lclc->size.size,&lclc->size.state);
      break;
    case 4:
      m5sprintf(output,"%s",&lclc->scan.scan,&lclc->scan.state);
      break;
    case 5:
      m5sprintf(output,"%s",&lclc->experiment.experiment,
		&lclc->experiment.state);
      break;
    case 6:
      m5sprintf(output,"%s",&lclc->station.station,&lclc->station.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}
void mk6_record_mon(output,count,lclm)
char *output;
int *count;
struct mk6_record_mon *lclm;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5key_encode(output,status_key,NSTATUS_KEY,
		   lclm->status.status,&lclm->status.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclm->group.group,&lclm->group.state);
      break;
    case 3:
      m5sprintf(output,"%d",&lclm->number.number,&lclm->number.state);
      break;
    case 4:
      m5sprintf(output,"%d",&lclm->name.name,&lclm->name.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}

mk6_record_2_m6(ptr,lcl)
char *ptr;
struct mk6_record_cmd *lcl;
{
  strcpy(ptr,"record = ");

  strcat(ptr,lcl->action.action);
  strcat(ptr," : ");
  

  sprintf(ptr+strlen(ptr),"%d,%d,%s,%s,$s"); /*need to fix */
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
m6_2_mk6_record(ptr_in,lclc,lclm,ip,who) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct mk6_record_cmd *lclc;  /* result structure with parameters */
     struct mk6_record_mon *lclm;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
     char *who;
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
      logita(NULL,errno,"un",who);
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
  memcpy(ip+3,"3r",2);
  memcpy(ip+4,who,2);
  return -1;
}
