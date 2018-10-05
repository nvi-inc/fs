/* dbbc3 ifx buffer parsing utilities */

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

int dbbc3_ifx_dec(lcl,count,ptr,itask)
struct dbbc3_ifx_cmd *lcl;
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
	if(ierr == 0 && (lcl->input < 1 || lcl->input > 2))
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
	break;
      default:
        *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbc3_ifx_enc(output,count,lcl)
char *output;
int *count;
struct dbbc3_ifx_cmd *lcl;
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
	if(lcl->target_null!=1)
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

void dbbc3_ifx_mon(output,count,lcl)
char *output;
int *count;
struct dbbc3_ifx_mon *lcl;
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

void ifx_2_dbbc3(buff,itask,lcl)
char *buff;
int itask;
struct dbbc3_ifx_cmd *lcl;

{
  int ivalue;
  static char ifx[] = {"abcdefgh"};

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

  if(lcl->target_null == 0 && lcl->target <= 65535u) {
    strcat(buff,",");  
    sprintf(buff+strlen(buff),"%u",lcl->target);
  }

  return;
}

int dbbc3_2_ifx(lclc,lclm,buff)
struct dbbc3_ifx_cmd *lclc;
struct dbbc3_ifx_mon *lclm;
char *buff;
{
  char *ptr, ch;
  int i, ierr, idum;

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
  if(1!=sscanf(ptr,"%d%c",&idum,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",&lclm->tp,&ch))
    return -1;

  ptr=strtok(NULL,",;");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",&lclc->target,&ch))
    return -1;
  lclc->target_null=0;
  
  return 0;
}
