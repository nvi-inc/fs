/* clock_set commmand buffer parsing utilities */

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

m5_2_clock_set(ptr_in,lclc,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct clock_set_cmd *lclc;  /* result structure with parameters */
     int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss, i;
  char string[33];

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-905;
    goto error;
  }

  m5state_init(&lclc->freq.state);
  m5state_init(&lclc->source.state);
  m5state_init(&lclc->clock_gen.state);

  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logit(NULL,errno,"un");
      ierr=-906;
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
        if(m5sscanf(ptr,"%d",&lclc->freq.freq,&lclc->freq.state)) {
	  ierr=-521;
	  goto error2;
	}
	break;
      case 2:
	if(m5string_decode(ptr,lclc->source.source,sizeof(lclc->source.source),
			   &lclc->source.state)) {
	  ierr=-522;
	  goto error2;
	}
	break;
      case 3:
        if(m5sscanf(ptr,"%lf",&lclc->clock_gen.clock_gen,
		    &lclc->clock_gen.state)) {
	  ierr=-523;
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
