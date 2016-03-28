/* ds SNAP command buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/ds_ds.h"

#define NUL	0x00
#define ACK	0x06
#define BEL	0x07
#define NAK	0x15

int ds_dec(lcl,count,ptr)
  struct ds_cmd *lcl;
  int *count;
  char *ptr;
{
    int ierr;

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
	lcl->type = DS_MON;
	lcl->data = 0;
        if(strlen(ptr)==0)
          ierr=-100;
        else
          if(strlen(ptr)!=2 || sscanf(ptr,"%2s",lcl->mnem) != 1)
            ierr=-200;
        break;
      case 2:
        if(strlen(ptr)==0)
          ierr=-100;
        else
          if(sscanf(ptr,"%3hd",&lcl->cmd) != 1 || lcl->cmd > 511 )
            ierr=-200;
        break;
      case 3:
        if(strlen(ptr)==0) break;
	lcl->type = DS_CMD;
        if(sscanf(ptr,"%4hx",&lcl->data) != 1 )
          ierr=-200;
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void ds_mon(output,count,lclm)
  char *output;
  int *count;
  struct ds_mon *lclm;
{
    output = output + strlen(output);

    switch (*count) {
      case 1:
        switch (lclm->resp) {
          case NUL:
            strcat(output,"NUL");
            break;
          case ACK:
            strcat(output,"ACK");
            break;
          case BEL:
            strcat(output,"BEL");
            break;
          case NAK:
            strcat(output,"NAK");
            break;
          default:
            sprintf(output,"0x%2.2x", lclm->resp);
        }
        break;
      case 2:
        switch (lclm->resp) {
          case ACK:
          case BEL:
            sprintf(output,"0x%4.4x", lclm->data.value);
            break;
          case NAK:
          case NUL:
            sprintf(output,"0x%2.2x", lclm->data.reg.warning);
            break;
          default:
            *count=-1;
        }
        break;
      case 3:
        switch (lclm->resp) {
          case NAK:
          case NUL:
            sprintf(output,"0x%2.2x", lclm->data.reg.error);
            break;
          default:
            *count=-1;
        }
        break;
      default:
       *count=-1;
   }
   return;
}
