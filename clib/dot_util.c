/* mk5b_mode commmand buffer parsing utilities */

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

char *m5trim();

m5_2_dot(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct dot_mon *lclm;  /* result structure with parameters */
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

  m5state_init(&lclm->time.state);
  m5state_init(&lclm->status.state);
  m5state_init(&lclm->FHG_status.state);
  m5state_init(&lclm->OS_time.state);
  m5state_init(&lclm->DOT_OS_time_diff.state);

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
	if(m5string_decode(ptr,lclm->time.time,sizeof(lclm->time.time),
			   &lclm->time.state)) {
	  ierr=-501;
	  goto error2;
	}
	break;
      case 2:
	if(m5string_decode(ptr,lclm->status.status,sizeof(lclm->status.status),
			   &lclm->status.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(m5string_decode(ptr,lclm->FHG_status.FHG_status,
			   sizeof(lclm->FHG_status.FHG_status),
			   &lclm->FHG_status.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 4:
	if(m5string_decode(ptr,lclm->OS_time.OS_time,
			   sizeof(lclm->OS_time.OS_time),
			   &lclm->OS_time.state)) {
	  ierr=-504;
	  goto error2;
	}
	break;
      case 5:
	if(m5string_decode(ptr,lclm->DOT_OS_time_diff.DOT_OS_time_diff,
			   sizeof(lclm->DOT_OS_time_diff.DOT_OS_time_diff),
			   &lclm->DOT_OS_time_diff.state)) {
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
  memcpy(ip+3,"5e",2);
  return -1;
}
