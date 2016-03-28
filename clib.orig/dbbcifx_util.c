/* dbbcifx buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *agc_key[ ]={"man","agc"};

#define NAGC_KEY sizeof(agc_key)/sizeof( char *)

int dbbcifx_dec(lcl,count,ptr,itask)
struct dbbcifx_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    int idefault;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_int(ptr,&lcl->input,0,FALSE);
	if(ierr == 0 && (lcl->input < 1 || lcl->input > 4))
	  ierr=-200;
        break;
      case 2:
	if(strcmp(ptr,"*")==0) {
	  if(strlen(ptr)!=1)
	    ierr=-200;
	  break;
	}
	lcl->att=-1;
	ierr=arg_key(ptr,agc_key,NAGC_KEY,&lcl->agc,1,TRUE);
	if(ierr==-200) {
	  ierr=arg_int(ptr,&lcl->att,0,FALSE);
	  if(ierr == 0 && (lcl->att < 0 || lcl->att > 63))
	    ierr=-200;
	  else if (ierr == 0)
	    lcl->agc=0;
	}
        break;
      case 3:
        ierr=arg_int(ptr,&lcl->filter,0,FALSE);
	if(ierr == 0 && (lcl->filter < 1 || lcl->filter > 8))
	  ierr=-200;
        break;
      case 4:
	if(0==strcmp(ptr,"*")) {
	  if(strlen(ptr)!=1)
	    ierr=-200;
	  break;
	}
	lcl->target_null=0;
	ierr=arg_uns(ptr,&lcl->target,0,FALSE);
	if(ierr == -100) {
	  lcl->target_null=1;
	  ierr=0;
	} else if(ierr == 0 && lcl->target > 65535u)
	  ierr=-200;	
	if(shm_addr->dbbcddcv<101 && lcl->target_null==0) /* overrides -200 */
	  ierr=-300;
	break;
      default:
        *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbcifx_enc(output,count,lcl)
char *output;
int *count;
struct dbbcifx_cmd *lcl;
{
    int ind, ivalue, whole, fract;

    output=output+strlen(output);

    switch (*count) {
      case 1:
	sprintf(output,"%d",lcl->input);
        break;
      case 2:
        ivalue = lcl->agc;
        if (ivalue >=0 && ivalue <NAGC_KEY)
          strcpy(output,agc_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
	sprintf(output,"%d",lcl->filter);
        break;
      case 4:
	if(shm_addr->dbbcddcv>100 && lcl->target_null!=1)
	  sprintf(output,"%u",lcl->target);
        break;
      case 5:
	if(lcl->att>=0)
	  sprintf(output,"%d",lcl->att);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbcifx_mon(output,count,lcl)
char *output;
int *count;
struct dbbcifx_mon *lcl;
{
    int ind;
    
    output=output+strlen(output);

    switch (*count) {
      case 1:
	sprintf(output,"%u",lcl->tp);
	break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void dbbcifx_2_dbbc(buff,itask,lcl)
char *buff;
int itask;
struct dbbcifx_cmd *lcl;

{
  int ivalue;
  static char ifx[] = {"abcd"};

  sprintf(buff,"dbbcif%c=",ifx[itask-1]);

  if(lcl->input > 0 && lcl->input < 5) 
    sprintf(buff+strlen(buff),"%d",lcl->input);
  strcat(buff,",");

  ivalue=lcl->agc;
  if(lcl->att >= 0 && lcl->att <65)
    sprintf(buff+strlen(buff),"%d",lcl->att);
  else if (ivalue >=0 && ivalue <NAGC_KEY)
    strcat(buff,agc_key[ivalue]);
  strcat(buff,",");  

  if(lcl->filter > 0 && lcl->filter < 9) 
    sprintf(buff+strlen(buff),"%d",lcl->filter);

  if(shm_addr->dbbcddcv>100) {
    if(lcl->target_null == 0 && lcl->target <= 65535u) {
      strcat(buff,",");  
      sprintf(buff+strlen(buff),"%u",lcl->target);
    }
  }

  return;
}

int dbbc_2_dbbcifx(lclc,lclm,buff)
struct dbbcifx_cmd *lclc;
struct dbbcifx_mon *lclm;
char *buff;
{
  char *ptr, ch;
  int i, ierr;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d%c",&lclc->input,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d%c",&lclc->att,&ch))
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_key(ptr,agc_key,NAGC_KEY,&lclc->agc,0,FALSE);
  if(ierr!=0 || 0==strcmp(ptr,"*"))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d%c",&lclc->filter,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",&lclm->tp,&ch))
    return -1;

  if(shm_addr->dbbcddcv <101)
    lclc->target_null=1;
  else {
    ptr=strtok(NULL,",");
    if(ptr==NULL)
      return -1;
    if(1!=sscanf(ptr,"%u%c",&lclc->target,&ch))
      return -1;
    lclc->target_null=0;
  }
  
  return 0;
}
