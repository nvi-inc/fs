/* data_check_util.c - utilities for mark 5 data_check command */

#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "../include/m5state_ds.h"
#include "../include/m5time_ds.h"
#include "../include/data_check_ds.h"

void data_check_mon(output,count,lcl)
char *output;
int *count;
struct data_check_mon *lcl;
{
  int tvgss;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    m5sprintf(output,"%s",lcl->mode.mode,&lcl->mode.state);
    break;
  case 2:
    tvgss=lcl->mode.state.known &&
      (strcmp(lcl->mode.mode,"tvg") == 0 ||
       strcmp(lcl->mode.mode,"SS") == 0);
    if(!tvgss)
      m5sprintf(output,"%s",lcl->submode.submode,&lcl->submode.state);
    else
      m5sprintf(output,"%ld",&lcl->submode.first,&lcl->submode.state);
    break;
  case 3:
    tvgss=lcl->mode.state.known &&
      (strcmp(lcl->mode.mode,"tvg") == 0 ||
       strcmp(lcl->mode.mode,"SS") == 0);
    if(!tvgss)
      m5time_encode(output,&lcl->time.time,&lcl->time.state);
    else
      m5sprintf(output,"%ld",&lcl->time.bad,&lcl->time.state);
    break;
  case 4:
    tvgss=lcl->mode.state.known &&
      (strcmp(lcl->mode.mode,"tvg") == 0 ||
       strcmp(lcl->mode.mode,"SS") == 0);
    if(!tvgss)
      m5sprintf(output,"%ld",&lcl->offset.offset,&lcl->offset.state);
    else
      m5sprintf(output,"%ld",&lcl->offset.size,&lcl->offset.state);
    break;
  case 5:
    m5time_encode(output,&lcl->period.period,&lcl->period.state);
    break;
  case 6:
    m5sprintf(output,"%ld",&lcl->bytes.bytes,&lcl->bytes.state);
    break;
  case 7:
    m5sprintf(output,"%Ld",&lcl->missing.missing,&lcl->missing.state);
    break;
  default:
    *count=-1;
  }
  
  if(*count > 0) *count++;
  return;
}

m5_2_data_check(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct data_check_mon *lclm;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  lclm->mode.state.known=0;
  lclm->mode.state.error=0;
  lclm->submode.state.known=0;
  lclm->submode.state.error=0;
  lclm->time.state.known=0;
  lclm->time.state.error=0;
  lclm->offset.state.known=0;
  lclm->offset.state.error=0;
  lclm->period.state.known=0;
  lclm->period.state.error=0;
  lclm->bytes.state.known=0;
  lclm->bytes.state.error=0;
  lclm->missing.state.known=0;
  lclm->missing.state.error=0;
    
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
	if(m5string_decode(ptr,&lclm->mode.mode,sizeof(lclm->mode.mode),
		  &lclm->mode.state)) {
	  ierr=-501;
	  goto error2;
	}
	if(0 == lclm->mode.state.known)
	  goto done;
	break;
      case 2:
	tvgss=lclm->mode.state.known &&
	  (strcmp(lclm->mode.mode,"tvg") == 0 ||
          strcmp(lclm->mode.mode,"SS") == 0);
	if(!tvgss) {
	  if(m5string_decode(ptr,&lclm->submode.submode,
			   sizeof(lclm->submode.submode),
			   &lclm->submode.state)) {
	    ierr=-502;
	    goto error2;
	  }
	} else
	  if(m5sscanf(ptr,"%ld",&lclm->submode.first,&lclm->submode.state)) {
	    ierr=-502;
	    goto error2;
	  }
	break;
      case 3:
	tvgss=lclm->mode.state.known &&
	  (strcmp(lclm->mode.mode,"tvg") == 0 ||
	   strcmp(lclm->mode.mode,"SS") == 0);
	if(!tvgss) {
	  if(m5time_decode(ptr,&lclm->time.time, &lclm->time.state)) {
	    ierr=-503;
	    goto error2;
	  }
	} else
	  if(m5sscanf(ptr,"%ld",&lclm->time.bad,&lclm->time.state)) {
	    ierr=-503;
	    goto error2;
	  }
	break;
      case 4:
	tvgss=lclm->mode.state.known &&
	  (strcmp(lclm->mode.mode,"tvg") == 0 ||
	   strcmp(lclm->mode.mode,"SS") == 0);
	if(!tvgss) {
	  if(m5sscanf(ptr,"%ld",&lclm->offset.offset, &lclm->offset.state)) {
	    ierr=-504;
	    goto error2;
	  }
	} else
	  if(m5sscanf(ptr,"%ld",&lclm->offset.size,&lclm->offset.state)) {
	    ierr=-504;
	    goto error2;
	  }
	break;
      case 5:
	if(m5time_decode(ptr,&lclm->period.period, &lclm->period.state)) {
	  ierr=-505;
	  goto error2;
	}
	break;
      case 6:
	if(m5sscanf(ptr,"%ld",&lclm->bytes.bytes, &lclm->bytes.state)) {
	  ierr=-506;
	  goto error2;
	}
      case 7:
	if(m5sscanf(ptr,"%Ld",&lclm->missing.missing, &lclm->missing.state)) {
	  ierr=-507;
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
  memcpy(ip+3,"5d",2);
  return -1;
}

