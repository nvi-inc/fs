/* dbbcgain buffer parsing utilities */

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

int dbbcgain_dec(lcl,count,ptr,itask)
struct dbbcgain_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key();

    int idefault;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_int(ptr,&lcl->bbc,0,FALSE);
	if(ierr==0) {
          if(DBBC==shm_addr->equip.rack && (lcl->bbc < 1 || lcl->bbc > 16))
	    ierr=-200;
          else if(DBBC3==shm_addr->equip.rack && (lcl->bbc < 1 || lcl->bbc > MAX_DBBC3_BBC))
	    ierr=-210;
	} else if(ierr == -200)
	  if(strcmp(ptr,"all")==0) {
	    lcl->bbc=0;
	    ierr=0;
	  }
        break;
      case 2:
	ierr=arg_key(ptr,agc_key,NAGC_KEY,&lcl->state,0,FALSE);
	if(ierr==-100) {
	  if(lcl->bbc!=0) {
	    lcl->state=-2;
	    ierr=0;
	  }
	} else if(ierr==-200) {
	  lcl->state=-1;
	  ierr=arg_int(ptr,&lcl->gainU,0,FALSE);
	  if(ierr==-100) {
	    lcl->state=-2;
	  } else if(ierr == 0 && (lcl->gainU < 1 || lcl->gainU > 255))
	    ierr=-200;
	}
        break;
      case 3:
	if(lcl->state == 1) {
	  ierr=arg_int(ptr,&lcl->target,0,FALSE);
	  if(ierr == 0 && (lcl->target < 0 || lcl->target > 65535))
	    ierr=-200;
	  else if(ierr==-100) {
	    lcl->target=-1;
	    ierr=0;
	  }
	} else if(lcl->state == -1) {
	  ierr=arg_int(ptr,&lcl->gainL,0,FALSE);
	  if(ierr == 0 && (lcl->gainL < 1 || lcl->gainL > 255))
	    ierr=-200;
	} else if(lcl->state == -2) {
	  ierr=arg_int(ptr,&lcl->target,0,FALSE);
	  if(ierr==-100)
	    ierr=0;
	  else if (ierr==0)
	    ierr=-200;
	}
        break;
      default:
        *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbcgain_enc(output,count,lcl)
char *output;
int *count;
struct dbbcgain_cmd *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
	if(lcl->bbc==0)
	  strcpy(output,"all");
        else
	  sprintf(output,"%d",lcl->bbc);
        break;
      case 2:
	if(lcl->state==-1)
	  sprintf(output,"%d",lcl->gainU);
	else if(lcl->state==-2)
	  *count=-1; /*nothing*/
	else {
	  ivalue = lcl->state;
	  if (ivalue >=0 && ivalue <NAGC_KEY)
	    strcpy(output,agc_key[ivalue]);
	  else
	    strcpy(output,BAD_VALUE);
	}
        break;
      case 3:
	if(lcl->state==-1)
	  sprintf(output,"%d",lcl->gainL);
	else if(lcl->state==-2)
	  *count=-1; /*nothing*/
	else if(lcl->state == 1)
	  sprintf(output,"%d",lcl->target);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbcgain_mon(output,count,lcl)
char *output;
int *count;
struct dbbcgain_mon *lcl;
{
    int ivalue;
    
    output=output+strlen(output);

    switch (*count) {
    case 1:
      ivalue = lcl->state;
      if (ivalue >=0 && ivalue <NAGC_KEY)
	strcpy(output,agc_key[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    case 2:
      if(lcl->state==1)
	sprintf(output,"%d",lcl->target);
      else
	*count=-1;
      break;
    default:
      *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void dbbcgain_2_dbbc(buff,itask,lcl)
char *buff;
int itask;
struct dbbcgain_cmd *lcl;

{
  int ivalue;
  static char ifx[] = {"abcd"};

  sprintf(buff,"dbbcgain=");

  if(lcl->bbc==0)
    strcpy(buff+strlen(buff),"all");
  else
    sprintf(buff+strlen(buff),"%d",lcl->bbc);

  if(lcl->state==-2)
    return;

  strcat(buff,",");
  if(lcl->state==-1) {
    sprintf(buff+strlen(buff),"%d",lcl->gainU);
    strcat(buff,",");
    sprintf(buff+strlen(buff),"%d",lcl->gainL);
  } else {
    ivalue=lcl->state;
    if (ivalue >=0 && ivalue <NAGC_KEY)
      strcat(buff,agc_key[ivalue]);
    if(lcl->state==1 && lcl->target!=-1) {
      strcat(buff,","); 
      sprintf(buff+strlen(buff),"%d",lcl->target);
    }
  }
  return;
}

int dbbc_2_dbbcgain(lclc,lclm,buff)
struct dbbcgain_cmd *lclc;
struct dbbcgain_mon *lclm;
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
  if(1!=sscanf(ptr,"%d%c",&lclc->bbc,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;

  lclc->state=-1;
  if(1!=sscanf(ptr,"%d%c",&lclc->gainU,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(1!=sscanf(ptr,"%d%c",&lclc->gainL,&ch))
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_key(ptr,agc_key,NAGC_KEY,&lclm->state,0,FALSE);
  if(ierr!=0 || 0==strcmp(ptr,"*"))
    return -1;

  if(lclm->state==1) {
    ptr=strtok(NULL,",");
    if(ptr==NULL)
    return -1;
    if(1!=sscanf(ptr,"%d%c",&lclm->target,&ch))
      return -1;
  }
  return 0;
}
