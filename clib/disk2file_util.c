/* mk5 disk2file commmand buffer parsing utilities */

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
	if(strlen(ptr)>sizeof(lcl->scan_label.scan_label)-1 ||
	   strlen(ptr)>63)
	  ierr=-200;
	else
	  strcpy(lcl->scan_label.scan_label,ptr);
	m5state_init(&lcl->scan_label.state);
	lcl->scan_label.state.known=1;
        break;
      case 2:
	if(strlen(ptr)>sizeof(lcl->destination.destination)-1)
	  ierr=-200;
	else
	  strcpy(lcl->destination.destination,ptr);
	m5state_init(&lcl->destination.state);
	lcl->destination.state.known=1;
        break;
      case 3:
	if(strlen(ptr)>sizeof(lcl->start.start)-1)
	  ierr=-200;
	else
	  strcpy(lcl->start.start,ptr);
	m5state_init(&lcl->start.state);
	lcl->start.state.known=1;
        break;
      case 4:
	if(strlen(ptr)>sizeof(lcl->end.end)-1)
	  ierr=-200;
	else
	  strcpy(lcl->end.end,ptr);
	m5state_init(&lcl->end.state);
	lcl->end.state.known=1;
        break;
      case 5:
	if(strlen(ptr)>sizeof(lcl->options.options)-1)
	  ierr=-200;
	else
	  strcpy(lcl->options.options,ptr);
	m5state_init(&lcl->options.state);
	lcl->options.state.known=1;
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
      m5sprintf(output,"%s",&lcl->scan_label.scan_label,
	        &lcl->scan_label.state);
      break;
    case 2:
      m5sprintf(output,"%s",&lcl->destination.destination,
		&lcl->destination.state);
      break;
    case 3:
      m5sprintf(output,"%s",&lcl->start.start,&lcl->start.state);
      break;
    case 4:
      m5sprintf(output,"%s",&lcl->end.end,&lcl->end.state);
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

    if(*count == 1 && (shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
	shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS ||
	shm_addr->equip.drive_type[0] == FLEXBUFF) )) {
      (*count)++;
    }

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

   return;
}

disk2file_2_m5_scan_set(ptr,lcl)
char *ptr;
struct disk2file_cmd *lcl;
{
  int i;

  strcpy(ptr,"scan_set = ");

  strcat(ptr,lcl->scan_label.scan_label);

  strcat(ptr," : ");

  strcat(ptr,lcl->start.start);

  strcat(ptr," : ");

  strcat(ptr,lcl->end.end);

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

  m5state_init(&lclc->scan_label.state);
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
  int count, ierr, mk5b;
  int i;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-911;
    goto error;
  }

  mk5b=shm_addr->equip.drive[0] == MK5 &&
    (shm_addr->equip.drive_type[0] ==MK5B ||
     shm_addr->equip.drive_type[0] == MK5B_BS ||
     shm_addr->equip.drive_type[0] ==MK5C ||
     shm_addr->equip.drive_type[0] == MK5C_BS ||
     shm_addr->equip.drive_type[0] == FLEXBUFF);
    
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
	if(!mk5b) {
	  if(m5sscanf(ptr,"%d",&lclm->scan_number.scan_number,
		      &lclm->scan_number.state)) {
	    ierr=-511;
	    goto error2;
	  }
	} else {
	  if(m5string_decode(ptr,lclc->scan_label.scan_label,
			     sizeof(lclc->scan_label.scan_label),
			     &lclc->scan_label.state)) {
	    ierr=-521;
	    goto error2;
	  }
	}
	break;
      case 2:
	if(!mk5b) {
	  if(m5string_decode(ptr,lclc->scan_label.scan_label,
			     sizeof(lclc->scan_label.scan_label),
			     &lclc->scan_label.state)) {
	    ierr=-512;
	    goto error2;
	  }
	} else {
	  if(m5string_decode(ptr,lclc->start.start,
			     sizeof(lclc->start.start),
			     &lclc->start.state)) {
	    ierr=-522;
	    goto error2;
	  }
	}
	break;
      case 3:
	if(!mk5b) {
	  if(m5string_decode(ptr,lclc->start.start,
			     sizeof(lclc->start.start),
			     &lclc->start.state)) {
	    ierr=-513;
	    goto error2;
	  }
	  break;
	} else {
	  if(m5string_decode(ptr,lclc->end.end,
			     sizeof(lclc->end.end),
			     &lclc->end.state)) {
	    ierr=-523;
	    goto error2;
	  }
	}
      case 4:
	if(!mk5b) {	
	  if(m5string_decode(ptr,lclc->end.end,
			     sizeof(lclc->end.end),
			     &lclc->end.state)) {
	    ierr=-514;
	    goto error2;
	  }
	} else {
	  goto done;
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
