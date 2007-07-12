/* mk5b_mode commmand buffer parsing utilities */

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

static char *source_key[ ]=         { "ext", "tvg","ramp" }; 

#define NSOURCE_KEY sizeof(source_key)/sizeof( char *)

char *m5trim();

int mk5b_mode_dec(lcl,count,ptr)
struct mk5b_mode_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();
    
    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,source_key,NSOURCE_KEY,&lcl->source.source,0,TRUE);
      m5state_init(&lcl->source.state);
      if(ierr==0) {
	lcl->source.state.known=1;
      } else {
	lcl->source.state.error=1;
      } 
      break;
    case 2:
      ierr=arg_int(ptr,&lcl->mask.mask ,0xffffffff,TRUE);
      m5state_init(&lcl->mask.state);
      if(ierr==0) {
	lcl->mask.state.known=1;
      } else {
	lcl->mask.state.error=1;
      } 
      break;
    case 3:
      ierr=arg_int(ptr,&lcl->decimate.decimate ,1,TRUE);
      m5state_init(&lcl->decimate.state);
      if(ierr==0) {
	lcl->decimate.state.known=1;
      } else {
	lcl->decimate.state.error=1;
      } 
      break;
    case 4:
      ierr=arg_int(ptr,&lcl->fpdp.fpdp ,0,FALSE);
      m5state_init(&lcl->fpdp.state);
      if(ierr==0) {
	lcl->fpdp.state.known=1;
      } else if(ierr==-100){
	ierr=0;
      } else{
	lcl->fpdp.state.error=1;
      }
      break;
    default:
      *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void mk5b_mode_enc(output,count,lclc)
char *output;
int *count;
struct mk5b_mode_cmd *lclc;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5key_encode(output,source_key,NSOURCE_KEY,
		     lclc->source.source,&lclc->source.state);
      break;
    case 2:
      sprintf(output,"0x%x",lclc->mask.mask);
      m5state_encode(output,&lclc->mask.state);
      break;
    case 3:
      sprintf(output,"%d",lclc->decimate.decimate);
      m5state_encode(output,&lclc->decimate.state);
      break;
    case 4:
      sprintf(output,"%d",lclc->fpdp.fpdp);
      m5state_encode(output,&lclc->fpdp.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}

mk5b_mode_2_m5(ptr,lclc)
char *ptr;
struct mk5b_mode_cmd *lclc;
{
  strcpy(ptr,"mode = ");

  strcat(ptr,source_key[lclc->source.source]);
  strcat(ptr," : ");

  sprintf(ptr+strlen(ptr),"0x%x",lclc->mask.mask);
  strcat(ptr," : ");

  sprintf(ptr+strlen(ptr),"%d",lclc->decimate.decimate);
  strcat(ptr," : ");

  if(lclc->fpdp.state.known==1) {
    sprintf(ptr+strlen(ptr),"%d ;\n",lclc->fpdp.fpdp);
  } else
    strcat(ptr+strlen(ptr)," ; \n ");

  return;
}
m5_2_mk5b_mode(ptr_in,lclc,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct mk5b_mode_cmd *lclc;  /* result structure with parameters */
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

  m5state_init(&lclc->source.state);
  m5state_init(&lclc->mask.state);
  m5state_init(&lclc->decimate.state);
  m5state_init(&lclc->fpdp.state);

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
	if(m5key_decode(ptr,&lclc->source,source_key,NSOURCE_KEY,
			&lclc->source.state)) {
	  ierr=-501;
	  goto error2;
	}
	break;
      case 2:
	if(m5sscanf(ptr,"%lx",&lclc->mask.mask,&lclc->mask.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(m5sscanf(ptr,"%d",&lclc->decimate.decimate,&lclc->decimate.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 4:
	if(m5sscanf(ptr,"%d",&lclc->fpdp.fpdp,&lclc->fpdp.state)) {
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
  memcpy(ip+3,"5t",2);
  return -1;
}
