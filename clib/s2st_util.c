/* S2 recorder st buffer parsing utilities */

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

static char *dir_key[ ]={"for"};
static char *speed_key[ ]={"sp","lp","slp"};
static char *state_key[ ]={"play","record","rewind","ff","stop","ppause",
			   "rpause","cue","review","notape","position"};
static char *state1_key[ ]={"off","on"};

#define STATE_KEY  sizeof(state_key)/sizeof( char *)
#define STATE1_KEY sizeof(state1_key)/sizeof( char *)
#define SPEED_KEY  sizeof(speed_key)/sizeof( char *)
#define DIR_KEY    sizeof(dir_key)/sizeof( char *)

int s2st_dec(lcl,count,ptr)
struct s2st_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;
    static int old_speed;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,dir_key,DIR_KEY,&lcl->dir,0,TRUE);
      break;      
    case 2:
      old_speed=lcl->speed;
      ierr=arg_key(ptr,speed_key,SPEED_KEY,&lcl->speed,-1,TRUE);
      if(ierr != 0 || lcl->speed == 0)
	ierr=-200;
      break;
    case 3:
      ierr=arg_key(ptr,state1_key,STATE1_KEY,&lcl->record,0,FALSE);
      if (ierr !=0)
	ierr=arg_key(ptr,state_key,STATE_KEY,&lcl->record,1,TRUE);
      if (ierr == 0) {
	lcl->record++;
	if (lcl->record < 1 || 2 < lcl->record)
	  ierr = -200;
	if (lcl->speed == -1) {
	  if (lcl->record == 2)
	    ierr=-100;
	  else
	    lcl->speed=old_speed;
	}
      }
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void s2st_enc(output,count,lcl)
char *output;
int *count;
struct s2st_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = lcl->dir;
    if (ivalue >=0 && ivalue <DIR_KEY)
      strcpy(output,dir_key[ivalue]);
    else
      sprintf(output,"0x%x",ivalue);
    break;
  case 2:
    ivalue = lcl->speed;
    if (ivalue >=0 && ivalue <SPEED_KEY)
      strcpy(output,speed_key[ivalue]);
    else if(ivalue == 0xff)
      strcpy(output,"unknown");
    else
      sprintf(output,"0x%x",ivalue);
    break;
  case 3:
    ivalue = lcl->record - 1;
    if (ivalue >=0 && ivalue <STATE_KEY)
      strcpy(output,state_key[ivalue]);
    else
      sprintf(output,"0x%x",ivalue);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}
