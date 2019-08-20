/* data_check_util.c - utilities for mark 5 data_check command */

#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void data_check_mon(output,count,lcl)
char *output;
int *count;
struct data_check_mon *lcl;
{
  int tvgss;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
	shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5sprintf(output,"%s",lcl->source.source,&lcl->source.state);
    } else {
      m5sprintf(output,"%s",lcl->mode.mode,&lcl->mode.state);
    }
    break;
  case 2:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5time_encode(output,&lcl->start.start,&lcl->start.state);
    } else {
      tvgss=lcl->mode.state.known &&
	(strcmp(lcl->mode.mode,"tvg") == 0 ||
	 strcmp(lcl->mode.mode,"SS") == 0);
      if(!tvgss)
	m5sprintf(output,"%s",lcl->submode.submode,&lcl->submode.state);
      else
	m5sprintf(output,"%d",&lcl->submode.first,&lcl->submode.state);
    }
    break;
  case 3:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5sprintf(output,"%d",&lcl->code.code,&lcl->code.state);
    } else {
      tvgss=lcl->mode.state.known &&
	(strcmp(lcl->mode.mode,"tvg") == 0 ||
	 strcmp(lcl->mode.mode,"SS") == 0);
      if(!tvgss)
	m5time_encode(output,&lcl->time.time,&lcl->time.state);
      else
	m5sprintf(output,"%d",&lcl->time.bad,&lcl->time.state);
    }
    break;
  case 4:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5sprintf(output,"%d",&lcl->frames.frames,&lcl->frames.state);
    } else {
      tvgss=lcl->mode.state.known &&
	(strcmp(lcl->mode.mode,"tvg") == 0 ||
	 strcmp(lcl->mode.mode,"SS") == 0);
      if(!tvgss)
	m5sprintf(output,"%d",&lcl->offset.offset,&lcl->offset.state);
      else
	m5sprintf(output,"%d",&lcl->offset.size,&lcl->offset.state);
    }
    break;
  case 5:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5time_encode(output,&lcl->header.header,&lcl->header.state);
    } else {
      m5time_encode(output,&lcl->period.period,&lcl->period.state);
    }
    break;
  case 6:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5sprintf(output,"%f",&lcl->total.total,&lcl->total.state);
    } else {
      m5sprintf(output,"%d",&lcl->bytes.bytes,&lcl->bytes.state);
    }
    break;
  case 7:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5sprintf(output,"%d",&lcl->byte.byte,&lcl->byte.state);
    } else {
      m5sprintf(output,"%Ld",&lcl->missing.missing,&lcl->missing.state);
    }
    break;
  case 8:
    if(shm_addr->equip.drive[0] == MK5 &&
       (shm_addr->equip.drive_type[0] ==MK5B ||
	shm_addr->equip.drive_type[0] == MK5B_BS ||
        shm_addr->equip.drive_type[0] ==MK5C ||
	shm_addr->equip.drive_type[0] == MK5C_BS) ) {
      m5sprintf(output,"%Ld",&lcl->missing.missing,&lcl->missing.state);
      break;
    }
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
     int ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss, mk5b;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }

  mk5b=shm_addr->equip.drive[0] == MK5 &&
    (shm_addr->equip.drive_type[0] ==MK5B ||
     shm_addr->equip.drive_type[0] == MK5B_BS ||
     shm_addr->equip.drive_type[0] ==MK5C ||
     shm_addr->equip.drive_type[0] == MK5C_BS);

  m5state_init(&lclm->missing.state);

  m5state_init(&lclm->mode.state);
  m5state_init(&lclm->submode.state);
  m5state_init(&lclm->time.state);
  m5state_init(&lclm->offset.state);
  m5state_init(&lclm->period.state);
  m5state_init(&lclm->bytes.state);
    
  m5state_init(&lclm->source.state);
  m5state_init(&lclm->start.state);
  m5state_init(&lclm->code.state);
  m5state_init(&lclm->frames.state);
  m5state_init(&lclm->header.state);
  m5state_init(&lclm->total.state);
  m5state_init(&lclm->byte.state);

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
	if(!mk5b) {
	  if(m5string_decode(ptr,&lclm->mode.mode,sizeof(lclm->mode.mode),
			     &lclm->mode.state)) {
	    ierr=-501;
	    goto error2;
	  }
	  if(0 == lclm->mode.state.known)
	    goto done;
	} else {
	  if(m5string_decode(ptr,&lclm->source.source,
			     sizeof(lclm->source.source),
			     &lclm->source.state)) {
	    ierr=-511;
	    goto error2;
	  }
	  if(0 == lclm->source.state.known)
	    goto done;
	}
	break;
      case 2:
	if(!mk5b) {
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
	    if(m5sscanf(ptr,"%d",&lclm->submode.first,&lclm->submode.state)) {
	      ierr=-522;
	      goto error2;
	    }
	} else {
	  if(m5time_decode(ptr,&lclm->start.start, &lclm->start.state)) {
	    ierr=-512;
	    goto error2;
	  }
	}
	break;
      case 3:
	if(!mk5b) {
	  tvgss=lclm->mode.state.known &&
	    (strcmp(lclm->mode.mode,"tvg") == 0 ||
	     strcmp(lclm->mode.mode,"SS") == 0);
	  if(!tvgss) {
	    if(m5time_decode(ptr,&lclm->time.time, &lclm->time.state)) {
	      ierr=-503;
	      goto error2;
	    }
	  } else
          if(m5sscanf(ptr,"%d",&lclm->time.bad,&lclm->time.state)) {
            ierr=-523;
            goto error2;
	  }
	} else {
	  if(m5sscanf(ptr,"%d",&lclm->code.code,&lclm->code.state)) {
	    ierr=-513;
	    goto error2;
	  }
	}
	break;
      case 4:
	if(!mk5b) {
	  tvgss=lclm->mode.state.known &&
	    (strcmp(lclm->mode.mode,"tvg") == 0 ||
	     strcmp(lclm->mode.mode,"SS") == 0);
	  if(!tvgss) {
	    if(m5sscanf(ptr,"%d",&lclm->offset.offset, &lclm->offset.state)) {
	      ierr=-504;
	      goto error2;
	    }
	  } else
	    if(m5sscanf(ptr,"%d",&lclm->offset.size,&lclm->offset.state)) {
	      ierr=-524;
	      goto error2;
	    }
	} else {
	  if(m5sscanf(ptr,"%d",&lclm->frames.frames,&lclm->frames.state)) {
	    ierr=-514;
	    goto error2;
	  }
	}
	break;
      case 5:
	if(!mk5b) {
	  if(m5time_decode(ptr,&lclm->period.period, &lclm->period.state)) {
	    ierr=-505;
	    goto error2;
	  }
	} else {
	  if(m5time_decode(ptr,&lclm->header.header, &lclm->header.state)) {
	    ierr=-515;
	    goto error2;
	  }
	}
	break;
      case 6:
	if(!mk5b) {
	  if(m5sscanf(ptr,"%d",&lclm->bytes.bytes, &lclm->bytes.state)) {
	    ierr=-506;
	    goto error2;
	  }
	} else {
	  if(m5sscanf(ptr,"%f",&lclm->total.total, &lclm->total.state)) {
	    ierr=-516;
	    goto error2;
	  }
	}
      case 7:
	if(!mk5b) {
	  if(m5sscanf(ptr,"%Ld",&lclm->missing.missing, &lclm->missing.state)) {
	    ierr=-507;
	    goto error2;
	  }
	} else {
	  if(m5sscanf(ptr,"%d",&lclm->byte.byte,&lclm->byte.state)) {
	    ierr=-517;
	    goto error2;
	  }
	}
	break;
      case 8:
	if(!mk5b) {
	  goto done;
	} else {
	  if(m5sscanf(ptr,"%Ld",&lclm->missing.missing,
		      &lclm->missing.state)) {
	    ierr=-518;
	    goto error2;
	  }
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

