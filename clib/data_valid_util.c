/* S2 recorder data_valid buffer parsing utilities */

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

static char *dv_key[ ]={"off","on"};
static char *pb_key[ ]={"ignore","use"};

#define DV_KEY  sizeof(dv_key)/sizeof( char *)
#define PB_KEY  sizeof(pb_key)/sizeof( char *)

int data_valid_dec(lcl,count,ptr)
struct data_valid_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,dv_key,DV_KEY,&lcl->user_dv,1,TRUE);
      break;      
    case 2:
      ierr=arg_key(ptr,pb_key,PB_KEY,&lcl->pb_enable,1,TRUE);
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void data_valid_enc(output,count,lcl)
char *output;
int *count;
struct data_valid_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = lcl->user_dv;
    if (ivalue >=0 && ivalue <DV_KEY)
      strcpy(output,dv_key[ivalue]);
    else
      sprintf(output,"0x%x",ivalue);
    break;
  case 2:
    ivalue = lcl->pb_enable;
    if (ivalue >=0 && ivalue <PB_KEY)
      strcpy(output,pb_key[ivalue]);
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
