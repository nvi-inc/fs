/* vsi4 buffer parsing utilities */

#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"
                                             /* parameter keywords */
static char *key_config[ ]={ "vlba","geo","tvg" };
                                          /* number of elem. keyword arrays */
#define NKEY_CONFIG sizeof(key_config)/sizeof( char *)

int vsi4_dec(lcl,count,ptr)
struct vsi4_cmd *lcl;
int *count;
char *ptr;
{
  int ierr, ind, arg_key(),len,i,j,k,ivalue,ish;
  unsigned mode, datain;
  int ioff, ifm;

  ierr=0;
  if(ptr == NULL) ptr="";

  switch (*count) {
  case 1:
    ierr=arg_key(ptr,key_config,NKEY_CONFIG,&lcl->config.value,0,FALSE);
    if(ierr==-100) {
      lcl->config.set=0;
      ierr=0;
    } else
      lcl->config.set=1;
    break;
  case 2:
    ierr=arg_int(ptr,&lcl->pcalx.value,0,FALSE);
    if(ierr==-100) {
      lcl->pcalx.set=0;
      ierr=0;
    } else if(ierr==0) {
      lcl->pcalx.set=1;
      if(lcl->pcalx.value<1 ||lcl->pcalx.value>16) 
	ierr=-200;
    }
    break;
  case 3:
    ierr=arg_int(ptr,&lcl->pcaly.value,0,FALSE);
    if(ierr==-100) {
      lcl->pcaly.set=0;
      ierr=0;
    } else if(ierr==0) {
      lcl->pcaly.set=1;
      if(lcl->pcaly.value<1 ||lcl->pcaly.value>16) 
	ierr=-200;
    }
    break;
  default:
    *count=-1;
  }
  if(ierr!=0) ierr-=*count;
done:
  if(*count>0) (*count)++;
  return ierr;
}

void vsi4_enc(output,count,lcl)
char *output;
int *count;
struct vsi4_cmd *lcl;
{
    int ind, ivalue, iokay, i, j;
    int a2d, clock, roll;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      if(!lcl->config.set)
	break;
      ivalue = lcl->config.value;
      if (ivalue >=0 && ivalue <NKEY_CONFIG)
	strcpy(output,key_config[ivalue]);
      else
	sprintf(output,"0x%x",ivalue);
      break;
    case 2:
      if(lcl->pcalx.set)
	sprintf(output,"%d",lcl->pcalx.value);
      break;
    case 3:
      if(lcl->pcaly.set)
	sprintf(output,"%d",lcl->pcaly.value);
      break;
    default:
      *count=-1;
      break;
   }
   if(*count>0) *count++;
   return;
}

void vsi4_mon(output,count,lcl)
char *output;
int *count;
struct vsi4_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      sprintf(output,"0x%x",lcl->version);
      break;
    default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void ma2vsi4(lclc,lclm,buff)
struct vsi4_cmd *lclc;
struct vsi4_mon *lclm;
char *buff;
{

  sscanf(buff+2,"%5x%1x%1x%1x",&lclm->version,
	     &lclc->pcaly.value,&lclc->pcalx.value,&lclc->config.value);
  lclc->config.set=1;
  lclc->pcalx.set=1;
  lclc->pcaly.set=1;
  
  lclc->pcalx.value++;
  lclc->pcaly.value++;

}

