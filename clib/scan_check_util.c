/* scan_check_util.c - utilities for mark 5 scan_check command */

#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void scan_check_mon(output,count,lcl)
char *output;
int *count;
struct scan_check_mon *lcl;
{
  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    m5sprintf(output,"%ld",&lcl->scan.scan,&lcl->scan.state);
    break;
  case 2:
    m5sprintf(output,"%s",lcl->label.label,&lcl->label.state);
    break;
  case 3:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
	shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS ||
	shm_addr->equip.drive_type[0] == FLEXBUFF) 
       ) {
      m5sprintf(output,"%s",lcl->type.type,&lcl->type.state);
    } else {
      m5sprintf(output,"%s",lcl->mode.mode,&lcl->mode.state);
    }
    break;
  case 4:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
	shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS ||
	shm_addr->equip.drive_type[0] == FLEXBUFF)
       ) {
      m5sprintf(output,"%d",&lcl->code.code,&lcl->code.state);
    } else {
      m5sprintf(output,"%s",lcl->submode.submode,&lcl->submode.state);
    }
    break;
  case 5:
    m5time_encode(output,&lcl->start.start,&lcl->start.state);
    break;
  case 6:
    m5time_encode(output,&lcl->length.length,&lcl->length.state);
    break;
  case 7:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
	shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS ||
	shm_addr->equip.drive_type[0] == FLEXBUFF)
       ) {
      m5sprintf(output,"%f",&lcl->total.total,&lcl->total.state);
    } else {
      m5sprintf(output,"%f",&lcl->rate.rate,&lcl->rate.state);
    }
    break;
  case 8:
    m5sprintf(output,"%Ld",&lcl->missing.missing,&lcl->missing.state);
    break;
  case 9:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
	shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS ||
	shm_addr->equip.drive_type[0] == FLEXBUFF)
       ) {
      m5sprintf(output,"%s",lcl->error.error,&lcl->error.state);
    } else {
      *count=-1;
    }
    break;
  default:
    *count=-1;
  }
  
  return;
}

m5_2_scan_check(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct scan_check_mon *lclm;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr, mk5b;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  mk5b=shm_addr->equip.drive[0] == MK5 &&
    (shm_addr->equip.drive_type[0] ==MK5B ||
     shm_addr->equip.drive_type[0] == MK5B_BS ||
     shm_addr->equip.drive_type[0] ==MK5C ||
     shm_addr->equip.drive_type[0] == MK5C_BS ||
     shm_addr->equip.drive_type[0] == FLEXBUFF);

  m5state_init(&lclm->scan.state);
  m5state_init(&lclm->label.state);
  m5state_init(&lclm->start.state);
  m5state_init(&lclm->length.state);
  m5state_init(&lclm->missing.state);

  m5state_init(&lclm->mode.state);
  m5state_init(&lclm->submode.state);
  m5state_init(&lclm->rate.state);

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
	if(m5sscanf(ptr,"%ld",&lclm->scan.scan, &lclm->scan.state)) {
	  ierr=-500-count;
	  goto error2;
	}
      case 2:
	if(m5string_decode(ptr,&lclm->label.label,sizeof(lclm->label.label),
		  &lclm->label.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 3:
	if(!mk5b) {
	  if(m5string_decode(ptr,&lclm->mode.mode,sizeof(lclm->mode.mode),
			     &lclm->mode.state)) {
	    ierr=-500-count;
	    goto error2;
	  }
	  if(0 == lclm->mode.state.known)
	    goto done;
	} else {
	  if(m5string_decode(ptr,&lclm->type.type,sizeof(lclm->type.type),
			     &lclm->type.state)) {
	    ierr=-510-count;
	    goto error2;
	  }
	  if(0==lclm->type.state.known)
	    goto done;
	}

	break;
      case 4:
	if(!mk5b) {
	  if(m5string_decode(ptr,&lclm->submode.submode,
			     sizeof(lclm->submode.submode),
			     &lclm->submode.state)) {
	    ierr=-500-count;
	    goto error2;
	  }
	} else {
	  if(m5sscanf(ptr,"%d",&lclm->code.code,&lclm->code.state)) {
	    ierr=-510-count;
	    goto error2;
	  }
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
	if(!mk5b) {
	  if(m5sscanf(ptr,"%f",&lclm->rate.rate, &lclm->rate.state)) {
	    ierr=-500-count;
	    goto error2;
	  }
	} else {
	  if(m5sscanf(ptr,"%f",&lclm->total.total, &lclm->total.state)) {
	    ierr=-510-count;
	    goto error2;
	  }
	} 
	break;
      case 8:
	if(m5sscanf(ptr,"%Ld",&lclm->missing.missing, &lclm->missing.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 9:
	if(!mk5b) {
	  goto done;
	} else {
	  if(m5string_decode(ptr,&lclm->error.error,sizeof(lclm->error.error),
			     &lclm->error.state)) {
	    ierr=-510-count;
	    goto error2;
	  }
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
  memcpy(ip+3,"5k",2);
  return -1;
}

