/* k4 label buffer parsing utilities */

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

int k4label_dec(lcl,count,ptr)
struct k4label_cmd *lcl;
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
      if(strlen(ptr)==8 || (strlen(ptr)==1 && ptr[0] =='#')) {
	int isize=sizeof(lcl->label);
	if(isize > strlen(ptr)+1)
	  isize=strlen(ptr)+1;
	strncpy(lcl->label,ptr,isize);
      } else
	ierr=-200;
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4label_enc(output,count,lcl)
char *output;
int *count;
struct k4label_cmd *lcl;
{
  int ivalue,idec,pos;
  static int ilo;


  output=output+strlen(output);
  
  switch (*count) {
      case 1:
	strcpy(output,lcl->label);
        break;
      default:
       *count=-1;
   }
  
  if(*count>0)
    *count++;
  return;
}

