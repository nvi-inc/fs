/* mk5 disk2file commmand buffer parsing utilities */

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

int disk2file_dec(lcl,count,ptr)
struct disk2file_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();
    char source[11];
    
    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
	if(strlen(ptr)>sizeof(lcl->scan_name.scan_name)-1)
	  ierr=-200;
	else
	  strcpy(lcl->scan_name.scan_name,ptr);
	lcl->scan_name.state.known=1;
	lcl->scan_name.state.error=0;
        break;
      case 2:
	if(strlen(ptr)>sizeof(lcl->destination.destination)-1)
	  ierr=-200;
	else if(strlen(ptr)==0)
	  ierr=-100;
	else
	  strcpy(lcl->destination.destination,ptr);
	lcl->destination.state.known=1;
	lcl->destination.state.error=0;
        break;
      case 3:
        ierr=arg_float(ptr,&lcl->start.start,0.0,FALSE);
        if(ierr==0 && lcl->start.start<0.0)
	  ierr=-200;
	else if(ierr==-100) {
	  lcl->start.start=-1;
	  ierr=0;
	}
	lcl->start.state.known=1;
	lcl->start.state.error=0;
        break;
      case 4:
        ierr=arg_float(ptr,&lcl->end.end,0.0,FALSE);
        if(ierr==0 && (lcl->end.end - lcl->start.start <= 0.000001 ))
	  ierr=-200;
	else if(ierr==-100) {
	  lcl->end.end=-1;
	  ierr=0;
	}
	lcl->end.state.known=1;
	lcl->end.state.error=0;
        break;
      case 5:
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

void disk2file_enc(output,count,lcl)
char *output;
int *count;
struct disk2file_cmd *lcl;
{

  int ivalue, i;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5sprintf(output,"%s",&lcl->scan_name.scan_name,&lcl->scan_name.state);
      break;
    case 2:
      m5sprintf(output,"%s",&lcl->destination.destination,
		&lcl->destination.state);
      break;
    case 3:
      if(lcl->start.start>0.0) {
	m5sprintf(output,"%f",&lcl->start.start,&lcl->start.state);
	for(i=strlen(output)-1;i>=0;i--) {
	  if(output[i]=='.') {
	    output[i]=0;
	    break;
	  }
	  if(output[i]!='0')
	    break;
	  output[i]=0;
	}
      }
      break;
    case 4:
      if(lcl->end.end>0.0) {
	m5sprintf(output,"%f",&lcl->end.end,&lcl->end.state);
	for(i=strlen(output)-1;i>=0;i--) {
	  if(output[i]=='.') {
	    output[i]=0;
	    break;
	  }
	  if(output[i]!='0')
	    break;
	  output[i]=0;
	}
      }
      break;
    case 5:
      m5sprintf(output,"%s",&lcl->options.options,&lcl->options.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}
void disk2file_mon(output,count,lcl)
char *output;
int *count;
struct disk2file_mon *lcl;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5sprintf(output,"%ld",&lcl->scan_number.scan_number,
		&lcl->scan_number.state);
      break;
    case 2:
      m5sprintf(output,"%s",&lcl->option.option,
		&lcl->option.state);
      break;
    case 3:
      m5sprintf(output,"%Ld",&lcl->start_byte.start_byte,
		&lcl->start_byte.state);
      break;
    case 4:
      m5sprintf(output,"%Ld",&lcl->end_byte.end_byte,
		&lcl->end_byte.state);
      break;
    case 5:
      m5sprintf(output,"%s",&lcl->status.status,
		&lcl->status.state);
      break;
    case 6:
      m5sprintf(output,"%Ld",&lcl->current.current,
		&lcl->current.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}

disk2file_2_m5_scan_set(ptr,lcl)
char *ptr;
struct disk2file_cmd *lcl;
{
  int i;

  strcpy(ptr,"scan_set = ");

  strcat(ptr,lcl->scan_name.scan_name);

  strcat(ptr," : ");

  if(lcl->start.start > 0.000001 ) {/*special case to avoid Mark5A bug */
    sprintf(ptr+strlen(ptr),"+%f",lcl->start.start);
    for(i=strlen(ptr)-1;i>=0;i--) {
      if(ptr[i]=='.') {
	ptr[i]=0;
	break;
      }
      if(ptr[i]!='0')
	break;
      ptr[i]=0;
    }
    strcat(ptr,"s");
  }
  strcat(ptr," : ");

  if(lcl->end.end > 0.0) {
    if(lcl->start.start>=0.0)
      sprintf(ptr+strlen(ptr),"+%f",lcl->end.end-lcl->start.start);
    else
      sprintf(ptr+strlen(ptr),"+%f",lcl->end.end);      
    for(i=strlen(ptr)-1;i>=0;i--) {
      if(ptr[i]=='.') {
	ptr[i]=0;
	break;
      }
      if(ptr[i]!='0')
	break;
      ptr[i]=0;
    }
    strcat(ptr,"s");
  }

  strcat(ptr," ; \n ");

  return;
}
disk2file_2_m5(ptr,lcl)
char *ptr;
struct disk2file_cmd *lcl;
{
  strcpy(ptr,"disk2file = ");

  strcat(ptr,lcl->destination.destination);

  strcat(ptr," : : : w ; \n ");

  return;
}
m5_2_disk2file(ptr_in,lclc,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct disk2file_cmd *lclc;  /* result structure with parameters */
     struct disk2file_mon *lclm;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int i;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  m5state_init(&lclc->scan_name.state);
  m5state_init(&lclc->destination.state);
  m5state_init(&lclc->start.state);
  m5state_init(&lclc->end.state);
  m5state_init(&lclc->options.state);
  m5state_init(&lclm->scan_number.state);
  m5state_init(&lclm->option.state);
  m5state_init(&lclm->start_byte.state);
  m5state_init(&lclm->end_byte.state);
  m5state_init(&lclm->status.state);
  m5state_init(&lclm->current.state);
    
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
	if(m5string_decode(ptr,lclm->status.status,
			   sizeof(lclm->status.status),
			   &lclm->status.state)) {
	  ierr=-501;
	  goto error2;
	}
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
	if(m5sscanf(ptr,"%Ld",&lclm->start_byte.start_byte,
		    &lclm->start_byte.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 4:
	if(m5sscanf(ptr,"%Ld",&lclm->current.current,
		    &lclm->current.state)) {
	  ierr=-504;
	  goto error2;
	}
	break;
      case 5:
	if(m5sscanf(ptr,"%Ld",&lclm->end_byte.end_byte,
		    &lclm->end_byte.state)) {
	  ierr=-505;
	  goto error2;
	}
	break;
      case 6:
	if(m5string_decode(ptr,lclm->option.option,
			   sizeof(lclm->option.option),
			   &lclm->option.state)) {
	  ierr=-506;
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
  memcpy(ip+3,"5f",2);
  return -1;
}
m5_scan_set_2_disk2file(ptr_in,lclc,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct disk2file_cmd *lclc;  /* result structure with parameters */
     struct disk2file_mon *lclm;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int i;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-911;
    goto error;
  }
    
  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logit(NULL,errno,"un");
      ierr=-912;
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
	if(m5sscanf(ptr,"%d",&lclm->scan_number.scan_number,
		    &lclm->scan_number.state)) {
	  ierr=-511;
	  goto error2;
	}
	break;
      case 2:
	if(m5string_decode(ptr,lclc->scan_name.scan_name,
			   sizeof(lclc->scan_name.scan_name),
			   &lclc->scan_name.state)) {
	  ierr=-512;
	  goto error2;
	}
	break;
      case 3:
	if(0 == lclm->start_byte.state.known)
	  if(m5sscanf(ptr,"%Ld",&lclm->start_byte.start_byte,
		      &lclm->start_byte.state)) {
	    ierr=-513;
	    goto error2;
	  }
	break;
      case 4:
	if(0 == lclm->end_byte.state.known)
	  if(m5sscanf(ptr,"%Ld",&lclm->end_byte.end_byte,
		      &lclm->end_byte.state)) {
	    ierr=-514;
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
  memcpy(ip+3,"5f",2);
  return -1;
}
