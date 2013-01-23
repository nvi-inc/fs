/* lo buffer parsing utilities */

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

static char *lom_key[ ]={"lo1","lo2","lo3"};
static char *lov_key[ ]={"loa","lob","loc","lod"};
static char *lol_key[ ]={"lo1","lo2","lo3","lo4"};
static char *sb_key[ ]={"unknown","usb","lsb"};
static char *pol_key[ ]={"unknown","rcp","lcp"};
static char *pcal_key[ ]={"unknown","off"};
static char *star_key[ ]={"*"};

#define LOM_KEY sizeof(lom_key)/sizeof( char *)
#define LOV_KEY sizeof(lov_key)/sizeof( char *)
#define LOL_KEY sizeof(lol_key)/sizeof( char *)
#define SB_KEY  sizeof(sb_key)/sizeof( char *)
#define POL_KEY sizeof(pol_key)/sizeof( char *)
#define PCAL_KEY sizeof(pcal_key)/sizeof( char *)
#define STAR_KEY sizeof(star_key)/sizeof( char *)

int lo_dec(lcl,count,ptr)
struct lo_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len, dum, i;
    static int lo;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else {
	if(shm_addr->equip.rack==MK4 || shm_addr->equip.rack==MK3 ||
	   shm_addr->equip.rack==K4 || shm_addr->equip.rack==K4MK4||
	   shm_addr->equip.rack==K4K3 )
	  ierr=arg_key(ptr,lom_key,LOM_KEY,&lo,0,FALSE);
	else if(shm_addr->equip.rack==VLBA4 || shm_addr->equip.rack==VLBA)
	  ierr=arg_key(ptr,lov_key,LOV_KEY,&lo,0,FALSE);
	else if(shm_addr->equip.rack==LBA || shm_addr->equip.rack==LBA4)
	  ierr=arg_key(ptr,lol_key,LOL_KEY,&lo,0,FALSE);
	else if(shm_addr->equip.rack==DBBC) {
	  ierr=arg_key(ptr,lov_key,LOV_KEY,&lo,0,FALSE);
	if(ierr==0 && lo >= shm_addr->dbbc_cond_mods)
	  ierr=-400;
	} else
	  ierr=arg_key(ptr,lol_key,LOL_KEY,&lo,0,FALSE);
	if(ierr==-100) {
	  for (i=0;i<4;i++) {
	    lcl->lo[i]=-1;
	    lcl->sideband[i]=0;
	  }
	  ierr=0;
	  *count=-1;
	}
      }
      break;
    case 2:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else
	ierr=arg_dble(ptr,&lcl->lo[lo],0.0,FALSE);
      break;
    case 3:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else
	ierr=arg_key(ptr,sb_key,SB_KEY,&lcl->sideband[lo],0,TRUE);
      break;
    case 4:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else
	ierr=arg_key(ptr,pol_key,POL_KEY,&lcl->pol[lo],0,TRUE);
      break;
    case 5:
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else {
	ierr=arg_key(ptr,pcal_key,PCAL_KEY,&lcl->pcal[lo],0,TRUE);
	if(ierr==0)
	  lcl->spacing[lo]=-1.0;
	else {
	  ierr=arg_dble(ptr,&lcl->spacing[lo],0.0,FALSE);
	  if(ierr==0 && lcl->spacing[lo] < 0)
	    ierr=-200;
	}
      }
      break;
    case 6:
      if(lcl->spacing[lo]<0) {
	*count=-1;
	break;
      }
      ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
      if(ierr == 0 && dum == 0)
	ierr=-300;
      else {
	ierr=arg_dble(ptr,&lcl->offset[lo],0.0,TRUE);
	if(ierr==0 && lcl->offset[lo] < 0)
	    ierr=-200;
	}
      break;

    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void lo_enc(output,count,lcl)
char *output;
int *count;
struct lo_cmd *lcl;
{
  int ivalue,idec,pos;
  static int ilo;

  output=output+strlen(output);

  if(*count == 1)
    ilo=0;
  else
    ilo++;

  while(ilo<4 && lcl->lo[ilo] <0)
    ilo++;
  if(ilo >= 4) {
    if(*count==1)
      strcpy(output,"undefined");
    else
      *count=-1;
    return;
  }

  if(shm_addr->equip.rack==MK4 || shm_addr->equip.rack==MK3 ||
     shm_addr->equip.rack==K4 || shm_addr->equip.rack==K4MK4 ||
     shm_addr->equip.rack==K4K3)
    strcpy(output,lom_key[ilo]);
  else if(shm_addr->equip.rack==VLBA4 || shm_addr->equip.rack==VLBA)
    strcpy(output,lov_key[ilo]);
  else if(shm_addr->equip.rack==LBA || shm_addr->equip.rack==LBA4)
    strcpy(output,lol_key[ilo]);
  else if(shm_addr->equip.rack==DBBC) {
    strcpy(output,lov_key[ilo]);
  } else
    strcpy(output,lol_key[ilo]);
  strcat(output,",");
  
  idec=16;
  if(lcl->lo[ilo] >= 1.0)
    idec-=log10(lcl->lo[ilo]);
  dble2str(output,lcl->lo[ilo],35,idec);
  pos=strlen(output)-1;
  while(output[pos]=='0') {
    output[pos]='\0';
    pos=strlen(output)-1;
  }
  pos=strlen(output)-1;
  if(output[pos]=='.')
    output[pos]='\0';
  strcat(output,",");

  ivalue = lcl->sideband[ilo];
  if (ivalue >=0 && ivalue <SB_KEY)
    strcat(output,sb_key[ivalue]);
  else
    strcat(output,BAD_VALUE);
  strcat(output,",");

  ivalue = lcl->pol[ilo];
  if (ivalue >=0 && ivalue <POL_KEY)
    strcat(output,pol_key[ivalue]);
  else
    strcat(output,BAD_VALUE);
  strcat(output,",");

  if(lcl->spacing[ilo] > 0) {
    idec=17;
    if(lcl->spacing[ilo] >= 1.0)
      idec-=log10(lcl->spacing[ilo]);
    dble2str(output,lcl->spacing[ilo],35,idec);
    pos=strlen(output)-1;
    while(output[pos]=='0') {
      output[pos]='\0';
      pos=strlen(output)-1;
    }
    pos=strlen(output)-1;
    if(output[pos]=='.')
      output[pos]='\0';
    strcat(output,",");
    idec=17;
    if(lcl->offset[ilo] >= 1.0)
      idec-=log10(lcl->offset[ilo]);
    dble2str(output,lcl->offset[ilo],35,idec);
    pos=strlen(output)-1;
    while(output[pos]=='0') {
      output[pos]='\0';
      pos=strlen(output)-1;
    }
    pos=strlen(output)-1;
    if(output[pos]=='.')
      output[pos]='\0';
  } else {
    ivalue = lcl->pcal[ilo];
    if (ivalue >=0 && ivalue <PCAL_KEY)
      strcat(output,pcal_key[ivalue]);
    else
      strcat(output,BAD_VALUE);
  }
  
  if(*count>0)
    *count++;
  return;
}
