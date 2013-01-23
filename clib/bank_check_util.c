/* mk5 rtime decoding for bank_check SNAP command */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

rtime_decode(rtime_mon,bank_set_mon,ip)
struct rtime_mon *rtime_mon;
struct bank_set_mon *bank_set_mon;
long ip[5];
{
      int ierr, count, i;
      char output[MAX_OUT],*start;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      long out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      long iclass, nrecs;

   /* decode buffers */

      iclass=ip[0];
      nrecs=ip[1];

      for (i=0;i<nrecs;i++) {
	char *ptr;
	if ((nchars =
	     cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
	  ip[3] = -411;
	  goto error2;
	}
	if(i==0) {
	  if(0!=m5_2_rtime(inbuf,rtime_mon,ip)) {
	    goto error;
	  }
	} else if(i==1) {
	  if(0!=m5_2_bank_set(inbuf,bank_set_mon,ip)) {
	    goto error;
	  }
	}

      }
      return 0;

error2:
      ip[2]=ierr;
      memcpy(ip+3,"5b",2);
error:
      ip[0]=0;
      ip[1]=0;
      cls_clr(iclass);
      return -1;

}
bank_set_check(done,ip)
int *done;
long ip[5];
{
  int out_recs,out_class;
  char outbuf[80];
  int ierr, count, i;
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE];
  long iclass, nrecs;

  *done=0;

  out_recs=0;
  out_class=0;
  ierr=0;
	
  strcpy(outbuf,"bank_set?\n");
  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
  out_recs++;
  
  ip[0]=5;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("mk5cn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) return;

  iclass=ip[0];
  nrecs=ip[1];

  for (i=0;i<nrecs;i++) {
    char *ptr;
    if ((nchars =
	 cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
      ip[3] = -421;
      goto error2;
    }
    if(i==0) { /* mush on even if there are decoding errors */
      ptr=strchr(inbuf,'?');
      if(ptr!=NULL && 1==sscanf(ptr+1,"%d",&ierr))
	if(ierr==0)
	  *done=1;
    }
  }

error2:
      ip[2]=ierr;
      memcpy(ip+3,"5b",2);
error:
      ip[0]=0;
      ip[1]=0;
      cls_clr(iclass);
      return;

}

m5_2_rtime(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rtime_mon *lclm; /* result structure with serial numbers
				    * blank means empty response
				    * null means no response
				    */
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
     shm_addr->equip.drive_type[0] == MK5B_BS);

  m5state_init(&lclm->seconds.state);
  m5state_init(&lclm->gb.state);
  m5state_init(&lclm->percent.state);
  m5state_init(&lclm->total_rate.state);

  m5state_init(&lclm->mode.state);
  m5state_init(&lclm->sub_mode.state);
  m5state_init(&lclm->track_rate.state);
  
  m5state_init(&lclm->source.state);
  m5state_init(&lclm->mask.state);
  m5state_init(&lclm->decimate.state);

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
	if(m5sscanf(ptr,"%lf",&lclm->seconds.seconds, &lclm->seconds.state)) {
	  ierr=-501;
	  goto error2;
	}
	if(lclm->seconds.seconds<0.0)
	  lclm->seconds.seconds=0.0;
	break;
      case 2:
	if(m5sscanf(ptr,"%lf",&lclm->gb.gb, &lclm->gb.state)) {
	  ierr=-502;
	  goto error2;
	}
	if(lclm->gb.gb<0.0)
	  lclm->gb.gb=0.0;
	break;
      case 3:
	if(m5sscanf(ptr,"%lf",&lclm->percent.percent, &lclm->percent.state)) {
	  ierr=-503;
	  goto error2;
	}
	if(lclm->percent.percent<1e-6)
	  lclm->percent.percent=0.0;
	break;
      case 4:
	if(!mk5b) {
	  if(m5string_decode(ptr,lclm->mode.mode,
			     sizeof(lclm->mode.mode),
			     &lclm->mode.state)) {
	    ierr=-504;
	    goto error2;
	  }
	} else { /* mk5b */
	  if(m5string_decode(ptr,lclm->source.source,
			     sizeof(lclm->source.source),
			     &lclm->source.state)) {
	    ierr=-534;
	    goto error2;
	  }
	}
	break;
      case 5:
	if(!mk5b) {
	  if(m5string_decode(ptr,lclm->sub_mode.sub_mode,
			     sizeof(lclm->sub_mode.sub_mode),
			     &lclm->sub_mode.state)) {
	    ierr=-505;
	    goto error2;
	  }
	} else { /* mk5b */
	  if(m5sscanf(ptr,"%lx",&lclm->mask.mask, &lclm->mask.state)) {
	    ierr=-535;
	    goto error2;
	  }
	}
	break;
      case 6:
	if(!mk5b) {
	  if(m5sscanf(ptr,"%lf",&lclm->track_rate.track_rate,
		      &lclm->track_rate.state)) {
	    ierr=-506;
	    goto error2;
	  }
	} else { /* mk5b */
	  if(m5sscanf(ptr,"%d",&lclm->decimate.decimate,
		      &lclm->decimate.state)) {
	    ierr=-536;
	    goto error2;
	  }
	}
	break;
      case 7:
	if(m5sscanf(ptr,"%lf",&lclm->total_rate.total_rate,
		    &lclm->total_rate.state)) {
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
      memcpy(ip+3,"5b",2);
      return -1;
}
m5_2_bank_set(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct bank_set_mon *lclm; /* result structure with serial numbers
				    * blank means empty response
				    * null means no response
				    */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save, *ptrd;
  int count, ierr;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-911;
    goto error;
  }

  m5state_init(&lclm->active_bank.state);
  m5state_init(&lclm->active_vsn.state);
  m5state_init(&lclm->inactive_bank.state);
  m5state_init(&lclm->inactive_vsn.state);

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
	if(m5string_decode(ptr,lclm->active_bank.active_bank,
			   sizeof(lclm->active_bank.active_bank),
			   &lclm->active_bank.state)) {
	  ierr=-511;
	  goto error2;
	}
	break;
      case 2:
	if(NULL!=(ptrd=strchr(ptr,'\x1e'))) /* truncate trailing junk */
	  *ptrd=0;
	if(m5string_decode(ptr,lclm->active_vsn.active_vsn,
			   sizeof(lclm->active_vsn.active_vsn),
			   &lclm->active_vsn.state)) {
	  ierr=-512;
	  goto error2;
	}
	break;
      case 3:
	if(m5string_decode(ptr,lclm->inactive_bank.inactive_bank,
			   sizeof(lclm->inactive_bank.inactive_bank),
			   &lclm->inactive_bank.state)) {
	  ierr=-513;
	  goto error2;
	}
	break;
      case 4:
	if(NULL!=(ptrd=strchr(ptr,'\x1e'))) /* truncate trailing junk */
	  *ptrd=0;
	if(m5string_decode(ptr,lclm->inactive_vsn.inactive_vsn,
			   sizeof(lclm->inactive_vsn.inactive_vsn),
			   &lclm->inactive_vsn.state)) {
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
      memcpy(ip+3,"5b",2);
      return -1;
}

m5_2_vsn(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct vsn_mon *lclm; /* result structure with vsn */

     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save, *ptrd;
  int count, ierr;

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-921;
    goto error;
  }
  m5state_init(&lclm->vsn.state);
  m5state_init(&lclm->check.state);
  m5state_init(&lclm->disk.state);
  m5state_init(&lclm->original_vsn.state);
  m5state_init(&lclm->new_vsn.state);

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
	if(NULL!=(ptrd=strchr(ptr,'\x1e'))) /* truncate trailing junk */
	  *ptrd=0;
	if(m5string_decode(ptr,lclm->vsn.vsn,
			   sizeof(lclm->vsn.vsn),
			   &lclm->vsn.state)) {
	  ierr=-521;
	  goto error2;
	}
	break;
      case 2:
	if(m5string_decode(ptr,lclm->check.check,
			   sizeof(lclm->check.check),
			   &lclm->check.state)) {
	  ierr=-522;
	  goto error2;
	}
	break;
      case 3:
	if(m5sscanf(ptr,"%d",&lclm->disk.disk, &lclm->disk.state)) {
	  ierr=-523;
	  goto error2;
	}
	break;
      case 4:
	if(m5string_decode(ptr,lclm->original_vsn.original_vsn,
			   sizeof(lclm->original_vsn.original_vsn),
			   &lclm->original_vsn.state)) {
	  ierr=-524;
	  goto error2;
	}
	break;
      case 5:
	if(m5string_decode(ptr,lclm->new_vsn.new_vsn,
			   sizeof(lclm->new_vsn.new_vsn),
			   &lclm->new_vsn.state)) {
	  ierr=-525;
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
      memcpy(ip+3,"5b",2);
      return -1;
}
