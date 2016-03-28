/* pcalform buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *chd_key[ ]={
  "1u","2u","3u","4u","5u","6u","7u","8u",
  "9u","10u","11u","12u","13u","14u","15u","16u",
  "1l","2l","3l","4l","5l","6l","7l","8l",
  "9l","10l","11l","12l","13l","14l","15l","16l"
};
static char *chh_key[ ]={
  "1u","2u","3u","4u","5u","6u","7u","8u",
  "9u","au","bu","cu","du","eu","fu","gu",
  "1l","2l","3l","4l","5l","6l","7l","8l",
  "9l","al","bl","cl","dl","el","fl","gl"
};
static char *star_key[ ]={"*"};

#define CHD_KEY sizeof(chd_key)/sizeof( char *)
#define CHH_KEY sizeof(chh_key)/sizeof( char *)
#define STAR_KEY sizeof(star_key)/sizeof( char *)

int pcalform_dec(lcl,count,ptr)
struct pcalform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len, dum, i, j, ch, tone;
    double freq;
    static int iconv, isb;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else {
	ierr=arg_key(ptr,chd_key,CHD_KEY,&ch,0,FALSE);
	if(ierr==-200)
	  ierr=arg_key(ptr,chh_key,CHH_KEY,&ch,0,FALSE);
	if(ierr==-100) {
	  for (i=0;i<2;i++)
	    for (j=0;j<16;j++)
	    lcl->count[i][j]=0;
	  ierr=0;
	  *count=-1;
	} else if(ierr==0){
	  iconv=ch%16;
	  isb=ch/16;
	  lcl->count[isb][iconv]=0;
	}
      }
      break;
    case 2:    case 3:    case 4:    case 5:    case 6:    case 7:    case 8:
    case 9:    case 10:    case 11:    case 12:    case 13:    case 14:
    case 15:   case 16:   case 17:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else if(ierr!=-100) {
	while(*ptr == ' ')
	  ptr++;
	lcl->strlen[isb][iconv][*count-2]=strlen(ptr);
	if(*ptr=='#') {
	  ptr++;
	  ierr=arg_int(ptr,&tone,0,FALSE);
	  if(ierr==0) {
	    lcl->count[isb][iconv]++;
	    lcl->which[isb][iconv][*count-2]=1;
	    lcl->tones[isb][iconv][*count-2]=tone;
	  }
	} else {
	  ierr=arg_dble(ptr,&freq,0.0,FALSE);
	  if(ierr==0) {
	    lcl->count[isb][iconv]++;
	    lcl->which[isb][iconv][*count-2]=0;
	    lcl->freqs[isb][iconv][*count-2]=freq;
	  }
	}
      } else {
	ierr=0;
	*count=-1;
      }
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void pcalform_enc(output,count,lcl)
char *output;
int *count;
struct pcalform_cmd *lcl;
{
  int ivalue,i;
  static int ich, inext;

  output=output+strlen(output);

  if(*count == 1) {
    ich=0;
    inext=0;
  } else if(inext >= lcl->count[ich/16][ich%16]) {
    ich++;
    inext=0;
  }

  if(inext == 0) {
    while(ich<32 && lcl->count[ich/16][ich%16] <= 0)
      ich++;
    if(ich >= 32) {
      if(*count==1)
	strcpy(output,"undefined");
      else
	*count=-1;
      return;
    }
  }

  strcpy(output,chd_key[ich]);
  strcat(output,",");
  
  for(i=inext;i<lcl->count[ich/16][ich%16];i++) {
    if(strlen(output) > 55-lcl->strlen[ich/16][ich%16][i]) {
      inext=i;
      goto end;
    }
    if(i!=inext)
      strcat(output,",");
    if(lcl->which[ich/16][ich%16][i]) {
      strcat(output,"#");
      int2str(output,lcl->tones[ich/16][ich%16][i],10,0);
    } else {
      int idec,iwid,pos;
      iwid=lcl->strlen[ich/16][ich%16][i]+2;
      if(0.9999999995 < lcl->freqs[ich/16][ich%16][i])
	idec=iwid-(2+log10(lcl->freqs[ich/16][ich%16][i]+.0000000005));
      else
	idec=iwid-2;
      dble2str(output,lcl->freqs[ich/16][ich%16][i],iwid,idec);
      pos=strlen(output)-1;
      while(output[pos]=='0') {
	output[pos]='\0';
	pos=strlen(output)-1;
      }
      pos=strlen(output)-1;
      if(output[pos]=='.')
	output[pos]='\0';
    }
  }
  inext=i;

 end:
  if(*count>0)
    *count++;
  return;
}
