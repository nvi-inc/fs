/* select command buffer parsing utilities */

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

static char *rc_key[ ]={"1","2"};

#define RC_KEY  sizeof(rc_key)/sizeof( char *)

int selectcmd_dec(lcl,count,ptr)
int *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,rc_key,RC_KEY,lcl,0,FALSE);
      break;      
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void selectcmd_enc(output,count,lcl)
char *output;
int *count;
int *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = *lcl;
    if (ivalue >=0 && ivalue <RC_KEY)
      strcpy(output,rc_key[ivalue]);
    else
      strcpy(output,"BAD_VALUE");
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}
