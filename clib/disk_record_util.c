/* vlba disk_record commmand buffer parsing utilities */

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
static char *record_display_key[ ]={ "off", "on", "halted","throttled",
				     "overflow", "waiting" }; 

#define NRECORD_KEY sizeof(record_key)/sizeof( char *)
#define NRECORD_DISPLAY_KEY sizeof(record_display_key)/sizeof( char *)

char *m5trim();

int disk_record_dec(lcl,count,ptr)
struct disk_record_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();
    char source[11];
    
    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,record_key,NRECORD_KEY,&lcl->record.record,0,FALSE);
	if(ierr==0) {
	  lcl->record.state.known=1;
	  lcl->record.state.error=0;
	} else {
	  lcl->record.state.known=0;
	  lcl->record.state.error=1;
	} 
        break;
      case 2:
	if(strlen(ptr) > sizeof(lcl->scan)-1) 
	  ierr=-200;
	else if(strlen(ptr) == 0 &&
		strlen(shm_addr->scan_name.name)>sizeof(lcl->scan)-1)
	  ierr=-300;
	else if(strlen(ptr) == 0)
	  strcpy(lcl->scan.scan,shm_addr->scan_name.name);
	else 
	  strcpy(lcl->scan.scan,ptr);
	if(ierr==0) {
	  lcl->scan.state.known=1;
	  lcl->scan.state.error=0;
	} else {
	  lcl->scan.state.known=0;
	  lcl->scan.state.error=1;
	} 
        break;
      case 3:
	if(strlen(ptr) > sizeof(lcl->session.session)-1) 
	  ierr=-200;
	else if(strlen(ptr) == 0 &&
		strlen(shm_addr->scan_name.session)>
		sizeof(lcl->session.session)-1)
	  ierr=-300;
	else if(strlen(ptr) == 0)
	  strcpy(lcl->session.session,shm_addr->scan_name.session);
	else 
	  strcpy(lcl->session.session,ptr);
	if(ierr==0) {
	  lcl->session.state.known=1;
	  lcl->session.state.error=0;
	} else {
	  lcl->session.state.known=0;
	  lcl->session.state.error=1;
	} 
        break;
      case 4:
	memcpy(source,shm_addr->lsorna,sizeof(source)-1);
	source[sizeof(source)-1]=0;

	for(i=strlen(source)-1;i>-1 && source[i]==' ';i--)
	  source[i]=0;

	if(strlen(ptr) > sizeof(lcl->source)-1) 
	  ierr=-200;
	else if(strlen(ptr) == 0 && strlen(source)>sizeof(lcl->source)-1)
	  ierr=-300;
	else if(strlen(ptr) == 0)
	  strcpy(lcl->source.source,source);
	else 
	  strcpy(lcl->source.source,ptr);
	if(ierr==0) {
	  lcl->source.state.known=1;
	  lcl->source.state.error=0;
	} else {
	  lcl->source.state.known=0;
	  lcl->source.state.error=1;
	} 
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void disk_record_enc(output,count,lcl)
char *output;
int *count;
struct disk_record_cmd *lcl;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5key_encode(output,record_display_key,NRECORD_DISPLAY_KEY,
		   lcl->record.record,&lcl->record.state);
      break;
    case 2:
      m5sprintf(output,"%s",lcl->scan.scan,&lcl->scan.state);
      break;
    case 3:
      m5sprintf(output,"%s",lcl->session.session,&lcl->session.state);
      break;
    case 4:
      m5sprintf(output,"%s",lcl->source.source,&lcl->source.state);
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
      m5sprintf(output,"%ld",&lcl->scan.scan,&lcl->scan.state);
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

  strcat(ptr,lcl->scan.scan);
  if(strlen(lcl->scan.scan)!=0)
    strcat(ptr," : ");
  else
    strcat(ptr,": ");

  strcat(ptr,lcl->session.session);
  if(strlen(lcl->session.session)!=0)
    strcat(ptr," : ");
  else
    strcat(ptr,": ");

  strcat(ptr,lcl->source.source);
  if(strlen(lcl->source.source)!=0)
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
     long ip[5];   /* standard parameter array */
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

  lclc->record.state.known=0;
  lclc->record.state.error=0;
  lclc->scan.state.known=0;
  lclc->scan.state.error=0;
  lclc->session.state.known=0;
  lclc->session.state.error=0;
  lclc->source.state.known=0;
  lclc->source.state.error=0;
  lclm->scan.state.known=0;
  lclm->scan.state.error=0;
    
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
	if(m5string_decode(ptr,&string,sizeof(string),
			   &lclc->record.state)) {
	  ierr=-501;
	  goto error2;
	}
	for (i=0;i<NRECORD_DISPLAY_KEY;i++) {
	  if(strcmp(string,record_display_key[i])==0) {
	    lclc->record.record=i;
	    goto found;
	  }
	}
	lclc->record.record=-1;
      found:
	break;
      case 2:
	if(m5sscanf(ptr,"%ld",&lclm->scan.scan,&lclm->scan.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(m5string_decode(ptr,lclc->scan.scan,sizeof(lclc->scan.scan),
			   &lclc->scan.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 4:
	if(m5string_decode(ptr,lclc->session.session,
			   sizeof(lclc->session.session),
			   &lclc->session.state)) {
	  ierr=-504;
	  goto error2;
	}
	break;
      case 5:
	if(m5string_decode(ptr,lclc->source.source,
			   sizeof(lclc->source.source),
			   &lclc->source.state)) {
	  ierr=-505;
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
