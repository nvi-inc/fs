/* mcb command buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/mcb_ds.h"

int mcb_dec(lcl,count,ptr)
struct mcb_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
        if(strlen(ptr)==0)
          memcpy(lcl->device,"\0",2);
        else
          memcpy(lcl->device,ptr,2);
        break;
      case 2:
        if(strlen(ptr)==0)
          ierr=-100;
        else
          if(1!=sscanf(ptr,"%x",&lcl->addr))
            ierr=-200;
        break;
      case 3:
        if(strlen(ptr)==0)
          lcl->cmd=0;
        else {
          lcl->cmd=1;
          if(1!=sscanf(ptr,"%x",&lcl->data))
            ierr=-200;
        }
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void mcb_mon(output,count,lcl)
char *output;
int *count;
struct mcb_mon *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%04.4x",0xFFFF & lcl->data);
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}
