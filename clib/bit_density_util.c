/* bit_density parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int bit_density_dec(lcl,count,ptr)
int *lcl;
int *count;
char *ptr;
{
    int ierr, arg_int();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_int(ptr,lcl,0,FALSE);
      if(ierr==0 && lcl <=0 )
	ierr = -200;
      break;
    default:
      *count=-1;
      break;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void bit_density_enc(output,count,lcl)
char *output;
int *count;
int *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        if(*lcl > 0)
           sprintf(output,"%d",*lcl);
        else
          strcpy(output,"UNDEFINED");
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}
