/* mk5 in2net commmand buffer parsing utilities */

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

static char *control_key[ ]=         { "off", "on","disconnect", "connect" }; 
static char *control_display_key[ ]= { "off", "on","disconnect", "connect",
                                       "inactive","connected","sending" }; 

#define NCONTROL_KEY sizeof(control_key)/sizeof( char *)
#define NCONTROL_DISPLAY_KEY sizeof(control_display_key)/sizeof( char *)

int in2net_dec(lcl,count,ptr)
struct in2net_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();
    char source[11];
    
    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,control_key,NCONTROL_KEY,
		     &lcl->control.control,0,FALSE);
	lcl->control.state.known=1;
	lcl->control.state.error=0;
        break;
      case 2:
	if(strlen(ptr)>sizeof(lcl->destination.destination)-1)
	  ierr=-200;
	else if(strlen(ptr)==0 && lcl->control.control==3)
	  ierr=-100;
	else
	  strcpy(lcl->destination.destination,ptr);
	lcl->destination.state.known=1;
	lcl->destination.state.error=0;
        break;
      case 3:
	if(strlen(ptr)>sizeof(lcl->options.options)-1)
	  ierr=-200;
	else
	  strcpy(lcl->options.options,ptr);
	lcl->options.state.known=1;
	lcl->options.state.error=0;
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void in2net_enc(output,count,lcl)
char *output;
int *count;
struct in2net_cmd *lcl;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5key_encode(output,control_display_key,NCONTROL_DISPLAY_KEY,
		   lcl->control.control,&lcl->control.state);
      break;
    case 2:
      m5sprintf(output,"%s",&lcl->destination.destination,
		&lcl->destination.state);
      break;
    case 3:
      m5sprintf(output,"%s",&lcl->options.options,&lcl->options.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}
void in2net_mon(output,count,lcl)
char *output;
int *count;
struct in2net_mon *lcl;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5sprintf(output,"%Ld",&lcl->received.received,
		&lcl->received.state);
      break;
    case 2:
      m5sprintf(output,"%Ld",&lcl->buffered.buffered,
		&lcl->buffered.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}

in2net_2_m5(ptr,lcl)
char *ptr;
struct in2net_cmd *lcl;
{
  strcpy(ptr,"in2net = ");

  if(lcl->control.control>=0 && lcl->control.control<NCONTROL_KEY) {
    strcat(ptr,control_key[lcl->control.control]);
    strcat(ptr," : ");
  } else
    strcat(ptr,": ");

  if(lcl->control.control==3) {
    strcat(ptr,lcl->destination.destination);
    strcat(ptr," ; \n ");
  } else
    strcat(ptr,"; \n ");

  return;
}
m5_2_in2net(ptr_in,lclc,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct in2net_cmd *lclc;  /* result structure with parameters */
     struct in2net_mon *lclm;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int i;
  char string[33];

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  m5state_init(&lclc->control.state);
  m5state_init(&lclc->destination.state);
  m5state_init(&lclc->options.state);
  m5state_init(&lclm->received.state);
  m5state_init(&lclm->buffered.state);
    
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
			   &lclc->control.state)) {
	  ierr=-501;
	  goto error2;
	}
	for (i=0;i<NCONTROL_DISPLAY_KEY;i++)
	  if(strcmp(string,control_display_key[i])==0) {
	    lclc->control.control=i;
	    goto found;
	  }
	lclc->control.control=-1;
      found:
	break;
      case 2:
	if(m5string_decode(ptr,lclc->destination.destination,
			   sizeof(lclc->destination.destination),
			   &lclc->destination.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(m5sscanf(ptr,"%Ld",&lclm->received.received,
		    &lclm->received.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 4:
	if(m5sscanf(ptr,"%Ld",&lclm->buffered.buffered,
		    &lclm->buffered.state)) {
	  ierr=-504;
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
  memcpy(ip+3,"5i",2);
  return -1;
}
