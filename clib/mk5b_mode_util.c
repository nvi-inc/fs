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

static char *source_key[ ]=         { "ext", "tvg","ramp","vdif","mark5b"}; 
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
    int isample;
    int decimate;
    char *sptr,*dptr;
    int idf;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      m5state_init(&lcl->source.state);
      if(14==itask)
	break;
      if(shm_addr->equip.drive[shm_addr->select] == MK5 &&
	 (shm_addr->equip.drive_type[shm_addr->select] == MK5B ||
	  shm_addr->equip.drive_type[shm_addr->select] == MK5B_BS))
	idf=0;
      else
	idf=3;
      ierr=arg_key(ptr,source_key,NSOURCE_KEY,&lcl->source.source,idf,TRUE);
      if(-200==ierr)
	if(shm_addr->equip.drive[shm_addr->select] == MK5 &&
	   (shm_addr->equip.drive_type[shm_addr->select] == MK5B ||
	    shm_addr->equip.drive_type[shm_addr->select] == MK5B_BS))
	  ierr=-210;
      if(ierr==0) {
	  if(shm_addr->equip.drive[shm_addr->select] == MK5 &&
	     (shm_addr->equip.drive_type[shm_addr->select] == MK5B ||
	      shm_addr->equip.drive_type[shm_addr->select] == MK5B_BS)) {
	    if(3<=lcl->source.source)
	      ierr=-210;
	  } else if(2>=lcl->source.source)
	    ierr=-200;
      }
      if(ierr==0) {
	lcl->source.state.known=1;
      } else {
	lcl->source.state.error=1;
      } 
      break;
    case 2:
      ierr=arg_long_long_uns(ptr,&lcl->mask.mask , 0xffffffffULL,TRUE);
      if(0==lcl->mask.mask)
	ierr=-200;   
      m5state_init(&lcl->mask.state);
      if(ierr==0) {
	lcl->mask.bits=0;
	for(i=0;i<64;i++) 
	  if(lcl->mask.mask & 0x1ULL<<i)
	    lcl->mask.bits++;
	
	lcl->mask.state.known=1;
      } else {
	lcl->mask.state.error=1;
      } 
      break;
    case 3:
      m5state_init(&lcl->decimate.state);
      if(14==itask)
	break;
      if(3!=lcl->source.source){ /* VSI or 5B/Ethernet */
	ierr=arg_int(ptr,&lcl->decimate.decimate ,1,FALSE);
	if(ierr == 0 && lcl->decimate.decimate!=1 &&
	   lcl->decimate.decimate!=2 &&
	   lcl->decimate.decimate!=4 &&
	   lcl->decimate.decimate!=8 &&
	   lcl->decimate.decimate!=16)
	  ierr=-200;
	if(ierr==0) {
	  if(shm_addr->m5b_crate/lcl->decimate.decimate < 2)
	    ierr=-210;
	  else {
	    lcl->decimate.datarate=1000000ULL*lcl->mask.bits
	      *(shm_addr->m5b_crate/lcl->decimate.decimate);
	    lcl->decimate.state.known=1;
	  }
	} else if(ierr!=-100) {
	  lcl->decimate.state.error=1;
	} 
	if(ierr==-100)
	  ierr=0;   /* default okay if sample is provided (next) */
      } else if(strlen(ptr)!=0)
	ierr=-220;   /* VDIF cannot specify decimation */
      break;
    case 4:
      m5state_init(&lcl->samplerate.state);
      if(14==itask)
	break;
      if(3>lcl->source.source){ /* VSI */
	sptr=dptr=strchr(ptr,'.');
	if(dptr!=NULL) {  /* get rid of trailing zeros after '.', and the '.' */
	  int zeros;
	  zeros=TRUE;
	  while(zeros && *++dptr != 0)
	    zeros = zeros && *dptr=='0';
	  if(zeros)
	    *sptr=0;
	}
	isample=lcl->samplerate.samplerate/1000000;
	ierr=arg_int(ptr,&isample,0,FALSE);
	if(lcl->decimate.state.known) {
	  if(ierr != -100)
	    ierr=-230;       /* can't have decimate and sample */
	  else if(ierr == -100) {
	    ierr = 0;         /* decimate was specified */
	    break;
	  }
	} else if(lcl->decimate.state.known == 0 && ierr == -100) {
	  if(0 == shm_addr->m5b_crate)
	    ierr=-100;     /*no default if no 5B Clock rate */
	  else {
	    isample=shm_addr->m5b_crate;
	    ierr=0;
	  }
	}
	if(ierr == 0 ) {
	  if(isample!=2 &&
	     isample!=4 &&
	     isample!=8 &&
	     isample!=16 &&
	     isample!=32 &&
	     isample!=64) {
	    ierr=-200;          /* Invalid sample */
	  } else {
	    decimate=shm_addr->m5b_crate/isample;
	    if( decimate!=1 &&
		decimate!=2 &&
		decimate!=4 &&
		decimate!=8 &&
		decimate!=16 ||  shm_addr->m5b_crate % isample !=0) {
	      ierr=-210;   /* invalid decimate */
	    }
	  }
	}
	if(ierr==0) {
	  lcl->samplerate.samplerate=isample*1000000ULL;
	  lcl->samplerate.datarate=isample*1000000ULL*lcl->mask.bits;
	  lcl->samplerate.decimate=decimate;
	  lcl->samplerate.state.known=1;
	} else {
	  lcl->samplerate.state.error=1;
	} 
      } else { /*  Ethernet */
	ierr=arg_long_long_uns_scal(ptr,&lcl->samplerate.samplerate,
				    0ULL,FALSE,6);
	if(-200==ierr || 0==lcl->samplerate.samplerate)
	  ierr=-240;
	else if(ierr==0) {
	  lcl->samplerate.datarate=lcl->mask.bits*lcl->samplerate.samplerate;
	  if(lcl->samplerate.datarate%1000000==0)
	    lcl->samplerate.state.known=1;
	  else
	    ierr=-220;     /* total rate not an integer multiple of 1 Mbps */
	} else if(-100==ierr)
	  if(lcl->decimate.state.known)
	    ierr = 0; /* it is okay if decimate was specified */
	  else 
	    ierr=-110;      /* no default for Ethernet unless decimate was
			       specified for mark5b */
	if(0!=ierr)
	  lcl->samplerate.state.error=1;
      }
      break;
    case 5:
      m5state_init(&lcl->fpdp.state);
      if(13!=itask)
	break;
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
    case 6:
      m5state_init(&lcl->disk.state);
      if(13!=itask)
	break;
      ierr=arg_key(ptr,disk_key,NDISK_KEY,&lcl->disk.disk,-1,TRUE);
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
      if(lclc->source.state.known)
	if(14==itask || (0<=lclc->source.source  && 3>lclc->source.source))
	  m5key_encode(output,source_key,NSOURCE_KEY,
		       lclc->source.source,&lclc->source.state);
	else
	  m5sprintf(output,"%s",lclc->source.magic,&lclc->source.state);
      break;
    case 2:
      if(lclc->mask.state.known)
	sprintf(output,"0x%llx",lclc->mask.mask);
      m5state_encode(output,&lclc->mask.state);
      break;
    case 3:
      m5sprintf(output,"%d",&lclc->decimate.decimate,&lclc->decimate.state);
      break;
    case 4:
      if(lclc->samplerate.state.known) {
	sprintf(output,"%llu.",lclc->samplerate.samplerate/1000000);
	if(lclc->samplerate.samplerate%1000000)
	  sprintf(output+strlen(output),"%06llu",
		  lclc->samplerate.samplerate%1000000);
	while(output[strlen(output)-1]=='0')
	  output[strlen(output)-1]=0;
	m5state_encode(output,&lclc->samplerate.state);
      } else if(shm_addr->mk5b_mode.samplerate.state.known) {
	sprintf(output,"(%llu.",
		shm_addr->mk5b_mode.samplerate.samplerate/1000000);
	if(shm_addr->mk5b_mode.samplerate.samplerate%1000000)
	  sprintf(output+strlen(output),"%06llu",
		  shm_addr->mk5b_mode.samplerate.samplerate%1000000);
	while(output[strlen(output)-1]=='0')
	  output[strlen(output)-1]=0;
	strcat(output,")");
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
      if(lclm->format.state.known)
	 m5sprintf(output,"%s",lclm->format.format,&lclm->format.state);
      break;
    case 2:
      m5sprintf(output,"%d",&lclm->tracks.tracks,&lclm->tracks.state);
      break;
    case 3:
      if(lclm->tbitrate.state.known) {
	sprintf(output,"%.6lf",lclm->tbitrate.tbitrate/1.0e6);
	while(output[strlen(output)-1]=='0')
	  output[strlen(output)-1]=0;
      }
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
  if(shm_addr->equip.drive[shm_addr->select] == MK5 &&
       (shm_addr->equip.drive_type[shm_addr->select] == MK5B ||
	shm_addr->equip.drive_type[shm_addr->select] == MK5B_BS)) {
    strcpy(ptr,"mode = ");

    strcat(ptr,source_key[lclc->source.source]);
    strcat(ptr," : ");

    sprintf(ptr+strlen(ptr),"0x%llx",lclc->mask.mask);
    strcat(ptr," : ");

    if(lclc->decimate.state.known)
      sprintf(ptr+strlen(ptr),"%d",lclc->decimate.decimate);
    else
      sprintf(ptr+strlen(ptr),"%d",lclc->samplerate.decimate);
    strcat(ptr," : ");
    
    if(lclc->fpdp.state.known==1) {
      sprintf(ptr+strlen(ptr),"%d ;\n",lclc->fpdp.fpdp);
    } else
      strcat(ptr+strlen(ptr)," ; \n ");

  } else { /* Mark 5C/FlexBuff */
    long long unsigned bitmask=lclc->mask.mask;
    int bits_p_chan = 0 ;
    long long unsigned data_rate = 0;
    int channels = 0;
    int i;
        
    if((0xaaaaaaaaaaaaaaaaULL & bitmask) && (0x555555555555555ULL & bitmask))
      bits_p_chan = 2 ;
    else if(bitmask)
      bits_p_chan = 1 ;  
    
    if(bits_p_chan > 0)
      channels = lclc->mask.bits/bits_p_chan;
    
    if(lclc->decimate.state.known)
      data_rate = lclc->decimate.datarate;
    else 
      data_rate = lclc->samplerate.datarate;
    
    if(4==lclc->source.source)
      strcpy(lclc->source.magic,"mark5b-");
    else
      strcpy(lclc->source.magic,"VDIF_8000-");
    snprintf(lclc->source.magic+strlen(lclc->source.magic),
	     sizeof(lclc->source.magic)-strlen(lclc->source.magic)-1,
	     "%llu-%d-%d",data_rate/1000000,channels,bits_p_chan);
    strncpy(shm_addr->mk5b_mode.source.magic,lclc->source.magic,
	    sizeof(shm_addr->mk5b_mode.source.magic));
    sprintf(ptr,"mode = %s ; \n",lclc->source.magic);
    
  }
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
	    lclc->source.source = -1;
	}
	break;
      case 2:
	if(lclc->source.state.known && -1 == lclc->source.source) {
	  if(m5sscanf(ptr,"%s",lclm->format.format,&lclm->format.state)) {
	    ierr=-512;
	    goto error2;
	  } 
	} else if(m5sscanf(ptr,"%llx",&lclc->mask.mask,&lclc->mask.state)) {
	  ierr=-502;
	  goto error2;
	}
	break;
      case 3:
	if(lclc->source.state.known && -1 == lclc->source.source) {
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
	if(lclc->source.state.known && -1 == lclc->source.source ) {
	  if(m5sscanf(ptr,"%lf",&lclm->tbitrate.tbitrate,
		      &lclm->tbitrate.state)) {
	    ierr=-514;
	    goto error2;
	  }
	} else {
	  if(m5sscanf(ptr,"%d",&lclc->fpdp.fpdp,&lclc->fpdp.state)) {
	    ierr=-504;
	    goto error2;
	  }
	}
	break;
      case 5:
	if(lclc->source.state.known && -1 == lclc->source.source &&
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
