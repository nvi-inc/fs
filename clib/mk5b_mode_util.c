/* mk5b_mode commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *source_key[ ]=         { "ext", "tvg","ramp","vdif"}; 
static char *disk_key[ ]=         { "disk_record_ok" }; 

#define NSOURCE_KEY sizeof(source_key)/sizeof( char *)
#define NDISK_KEY sizeof(disk_key)/sizeof( char *)

char *m5trim();

int mk5b_mode_dec(lcl,count,ptr, itask)
struct mk5b_mode_cmd *lcl;
int *count;
char *ptr;
int itask;
{
    int ierr, i, arg_key();
    float sample;
    int decimate;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,source_key,NSOURCE_KEY,&lcl->source.source,0,TRUE);
      m5state_init(&lcl->source.state);
      if(ierr==0) {
	if(3==lcl->source.source) {
	  if(13 != itask) {
	    strcpy(lcl->source.magic,"vdif");
	  } else {
	    ierr=-220;
	  } 
	}
      }
      if(ierr==0) {
	lcl->source.state.known=1;
      } else {
	lcl->source.state.error=1;
      } 
      break;
    case 2:
      ierr=arg_int(ptr,&lcl->mask.mask ,0xffffffff,TRUE);
      if(0==lcl->mask.mask)
	ierr=-200;
      m5state_init(&lcl->mask.state);
      if(ierr==0) {
	lcl->mask.state.known=1;
      } else {
	lcl->mask.state.error=1;
      } 
      break;
    case 3:
      lcl->decimate.decimate=0;
      ierr=arg_int(ptr,&lcl->decimate.decimate ,1,FALSE);
      m5state_init(&lcl->decimate.state);
      if(ierr == 0 && lcl->decimate.decimate!=1 &&
	 lcl->decimate.decimate!=2 &&
	 lcl->decimate.decimate!=4 &&
	 lcl->decimate.decimate!=8 &&
	 lcl->decimate.decimate!=16)
	ierr=-200;
      if(ierr==0) {
	lcl->decimate.state.known=1;
      } else if(ierr!=-100) {
	lcl->decimate.state.error=1;
      } 
      if(ierr==-100)
	ierr=0;
      break;
    case 4:
      ierr=arg_float(ptr,&sample,0.0,FALSE);
      m5state_init(&lcl->samplerate.state);
      if(lcl->decimate.state.known != 0) {
	if(ierr != -100)
	  ierr=-300;
	else if(ierr == -100) {
	  ierr = 0;
	  break;
	}
      } else if(lcl->decimate.state.known == 0 && ierr == -100) {
	if(0 == shm_addr->m5b_crate)
	  ierr=-100;
	else {
	  sample=shm_addr->m5b_crate;
	  ierr=0;
	}
      }
      if(ierr == 0 ) {
	if(sample <= 0.124) {
	  ierr=-200;
	} else {
	  decimate=(shm_addr->m5b_crate/sample)+0.1;
	  if( fabs(decimate*sample-shm_addr->m5b_crate)/
	      shm_addr->m5b_crate > 0.001)
	    ierr=-210;
	  else if( decimate!=1 &&
		   decimate!=2 &&
		   decimate!=4 &&
		   decimate!=8 &&
		   decimate!=16) {
	    ierr=-210;
	  }
	}
      }
      if(ierr==0) {
	lcl->samplerate.samplerate=sample;
	lcl->samplerate.decimate=decimate;
	lcl->samplerate.state.known=1;
      } else {
	lcl->samplerate.state.error=1;
      } 
      break;
    case 5:
      m5state_init(&lcl->fpdp.state);
      if(13==itask) {
	ierr=arg_int(ptr,&lcl->fpdp.fpdp ,0,FALSE);
	if(ierr==0 && lcl->fpdp.fpdp != 1 && lcl->fpdp.fpdp != 2)
	  ierr=-200;
	if(ierr==0) {
	  lcl->fpdp.state.known=1;
	} else if(ierr==-100){
	  ierr=0;
	} else{
	  lcl->fpdp.state.error=1;
	}
	break;
      }
    case 6:
      m5state_init(&lcl->disk.state);
      if(14==itask)
	break;
      else if(13!=itask)
	(*count)++;
      ierr=arg_key(ptr,disk_key,NDISK_KEY,&lcl->disk.disk,-1,TRUE);
      m5state_init(&lcl->disk.state);
      if(ierr==0) {
	lcl->disk.state.known=1;
      } else {
	lcl->disk.state.error=1;
      } 
      break;
    default:
      *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void mk5b_mode_enc(output,count,lclc,lclm,itask)
char *output;
int *count;
struct mk5b_mode_cmd *lclc;
struct mk5b_mode_mon *lclm;
int itask;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      if(lclc->source.state.known && lclc->source.source == 3)
	m5sprintf(output,"%s",lclc->source.magic,&lclc->source.state);
      else
	m5key_encode(output,source_key,NSOURCE_KEY,
		     lclc->source.source,&lclc->source.state);
      break;
    case 2:
      if(lclc->mask.state.known)
	sprintf(output,"0x%x",lclc->mask.mask);
      m5state_encode(output,&lclc->mask.state);
      break;
    case 3:
      m5sprintf(output,"%d",&lclc->decimate.decimate,&lclc->decimate.state);
      break;
    case 4:
      if(lclc->samplerate.state.known) {
	sprintf(output,"%.3f",lclc->samplerate.samplerate);
	m5state_encode(output,&lclc->samplerate.state);
      } else if(shm_addr->mk5b_mode.samplerate.state.known &&
		!lclm->tbitrate.state.known) {
	  sprintf(output,"(%.3f)",shm_addr->mk5b_mode.samplerate.samplerate);
	  m5state_encode(output,&shm_addr->mk5b_mode.samplerate.state);
      }
      break;
    case 5:
      if(13==itask) {
	 m5sprintf(output,"%d",&lclc->fpdp.fpdp,&lclc->fpdp.state);
	 break;
      }
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}
void mk5b_mode_mon(output,count,lclm)
char *output;
int *count;
struct mk5b_mode_mon *lclm;
{

  int ivalue;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      m5sprintf(output,"%s",lclm->format.format,&lclm->format.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclm->tracks.tracks,&lclm->tracks.state);
      break;
    case 3:
      if(lclm->tbitrate.state.known)
	sprintf(output,"%.3f",lclm->tbitrate.tbitrate/1.0e6);
      m5state_encode(output,&lclm->tbitrate.state);
      break;
    case 4:
      m5sprintf(output,"%d",&lclm->framesize.framesize,&lclm->framesize.state);
      break;
    default:
      *count=-1;
   }

   if(*count>0) *count++;
   return;
}

mk5b_mode_2_m5(ptr,lclc,itask)
char *ptr;
struct mk5b_mode_cmd *lclc;
int itask;
{
  if(lclc->source.source!=3) {
    strcpy(ptr,"mode = ");

    strcat(ptr,source_key[lclc->source.source]);
    strcat(ptr," : ");

    sprintf(ptr+strlen(ptr),"0x%x",lclc->mask.mask);
    strcat(ptr," : ");

    if(15 != itask) {
      if(lclc->decimate.state.known)
	sprintf(ptr+strlen(ptr),"%d",lclc->decimate.decimate);
      else
	sprintf(ptr+strlen(ptr),"%d",lclc->samplerate.decimate);
      strcat(ptr," : ");
    } else
      strcat(ptr," 1 : ");
    
    if(lclc->fpdp.state.known==1) {
      sprintf(ptr+strlen(ptr),"%d ;\n",lclc->fpdp.fpdp);
    } else
      strcat(ptr+strlen(ptr)," ; \n ");

  } else {
    int bits=0;
    int bitmask=lclc->mask.mask;
    int bits_p_chan = 0 ;
    int data_rate = 0;
    int channels = 0;
    int i;
    
    for(i=0;i<32;i++) 
      if(bitmask & 0x1<<i)
	bits++;
    
    if((0xaaaaaaaa & bitmask) && (0x5555555 & bitmask))
      bits_p_chan = 2 ;
    else if(bitmask)
      bits_p_chan = 1 ;  
    
    if(bits_p_chan > 0)
      channels = bits/bits_p_chan;
    
    if(lclc->decimate.state.known && lclc->decimate.decimate > 0)
      data_rate = bits*shm_addr->m5b_crate/lclc->decimate.decimate;
    else
      data_rate = bits*shm_addr->m5b_crate/lclc->samplerate.decimate;
    
    snprintf(lclc->source.magic,sizeof(lclc->source.magic),
	     "VDIF_8000-%d-%d-%d",data_rate,channels,bits_p_chan);
    strncpy(shm_addr->mk5b_mode.source.magic,lclc->source.magic,
	    sizeof(shm_addr->mk5b_mode.source.magic));
    sprintf(ptr,"mode = %s ; \n",lclc->source.magic);
    
  }
  return;
}
mk5c_clock_set_2_m5(ptr,lclc)
char *ptr;
struct mk5b_mode_cmd *lclc;
{
  strcpy(ptr,"clock_set = ");

  if(lclc->samplerate.state.known)
    sprintf(ptr+strlen(ptr),"%.3f : ext ; \n",
	    lclc->samplerate.samplerate+0.0001);
  else
    sprintf(ptr+strlen(ptr),"%d : ext ; \n",
	    shm_addr->m5b_crate/lclc->decimate.decimate);

  return;
}

m5_2_mk5b_mode(ptr_in,lclc,lclm,itask,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct mk5b_mode_cmd *lclc;  /* result structure with parameters */
     struct mk5b_mode_mon *lclm;  /* result structure with parameters */
     int itask;
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
  m5state_init(&lclc->samplerate.state);
  m5state_init(&lclc->fpdp.state);
  m5state_init(&lclm->format.state);
  m5state_init(&lclm->tracks.state);
  m5state_init(&lclm->tbitrate.state);
  m5state_init(&lclm->framesize.state);

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
	  if(m5sscanf(ptr,"%s",lclc->source.magic,&lclc->source.state)) {
	    ierr=-501;
	    goto error2;
	  } else
	    lclc->source.source = 3;
	}
	break;
      case 2:
	if(lclc->source.state.known && 3 == lclc->source.source) {
	  if(m5sscanf(ptr,"%s",lclm->format.format,&lclm->format.state)) {
	    ierr=-512;
	    goto error2;
	  } 
	} else if(m5sscanf(ptr,"%lx",&lclc->mask.mask,&lclc->mask.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(lclc->source.state.known && 3 == lclc->source.source) {
	  if(m5sscanf(ptr,"%d",&lclm->tracks.tracks,&lclm->tracks.state)) {
	  ierr=-513;
	  goto error2;
	  }
	} else if(m5sscanf(ptr,"%d",
			   &lclc->decimate.decimate,&lclc->decimate.state)) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 4:
	if(lclc->source.state.known && 3 == lclc->source.source || itask == 15) {
	  if(m5sscanf(ptr,"%f",&lclm->tbitrate.tbitrate,&lclm->tbitrate.state)) {
	    ierr=-514;
	    goto error2;
	  }
	} else if(13 == itask) {
	  if(m5sscanf(ptr,"%d",&lclc->fpdp.fpdp,&lclc->fpdp.state)) {
	    ierr=-504;
	    goto error2;
	  }
	}
	break;
      case 5:
	if(lclc->source.state.known && 3 == lclc->source.source &&
	   !strncasecmp(lclc->source.magic,"VDIF",4)) {
	  if(m5sscanf(ptr,"%d",
		      &lclm->framesize.framesize,&lclm->framesize.state)) {
	    ierr=-505;
	    goto error2;
	  }
	  break;
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
  memcpy(ip+3,"5t",2);
  return -1;
}
