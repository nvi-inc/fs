/* dbbc_cont_cal buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/dbbc_cont_cal_ds.h"

static char *mode_key[ ]={"off","on"};

#define NMODE_KEY sizeof(mode_key)/sizeof( char *)

int dbbc_cont_cal_dec(lcl,count,ptr,polarity_control)
struct dbbc_cont_cal_cmd *lcl;
int *count, polarity_control;
char *ptr;
{
    int ierr, ind, arg_key();

    int idefault;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
	ierr=arg_key(ptr,mode_key,NMODE_KEY,&lcl->mode,0,TRUE);
        break;
      case 2:
	if(0x1 & polarity_control) {
	  ierr=arg_int(ptr,&lcl->polarity,0,FALSE);
	  if(ierr==-100)
	    ierr=0;  /*old value is the default */
	  else if(ierr==0 && (lcl->polarity < -1 ||lcl->polarity > 3))
	    ierr=-200;
	} else {
	  ierr=arg_int(ptr,&lcl->polarity,0,FALSE);
	  if(ierr!=-100)
	    ierr=-210;
	  else {
	    ierr=0;
	    lcl->polarity=-1;
	  }
	}
	break;
    case 3:
      ierr=arg_int(ptr,&lcl->samples,10,TRUE);
      if(ierr == 0 && lcl->samples < 1)
	ierr=-200;
      break;
    case 4:
      if(0x2 & polarity_control) {
	ierr=arg_int(ptr,&lcl->freq,0,FALSE);
	if(ierr==-100)
	  ierr=0;  /*old value is the default */
	else if(ierr==0 && (lcl->freq < 8 ||lcl->freq > 300000)
		&& lcl->freq!=-1)
	  ierr=-200;
      } else {
	ierr=arg_int(ptr,&lcl->freq,0,FALSE);
	if(ierr!=-100)
	  ierr=-210;
	else {
	  ierr=0;
	  lcl->freq=-1;
	}
      }
      break;
    case 5:
      if(0x2 & polarity_control) {
	ierr=arg_int(ptr,&lcl->option,0,FALSE);
	if(ierr==-100)
	  ierr=0;  /*old value is the default */
	else if(ierr==0 && (lcl->option < -1 ||lcl->option > 1))
	  ierr=-200;
      } else {
	ierr=arg_int(ptr,&lcl->option,0,FALSE);
	if(ierr!=-100)
	  ierr=-210;
	else {
	  ierr=0;
	  lcl->option=-1;
	}
      }
      break;
    default:
      *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbc_cont_cal_enc(output,count,lcl)
char *output;
int *count;
struct dbbc_cont_cal_cmd *lcl;
{
    int ind, ivalue, whole, fract;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue = lcl->mode;
        if (ivalue >=0 && ivalue <NMODE_KEY)
          strcpy(output,mode_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
	if(lcl->polarity>=0)
	  sprintf(output,"%d",lcl->polarity);
        break;
      case 3:
	sprintf(output,"%d",lcl->samples);
        break;
      case 4:
	if(lcl->freq>=0)
	  sprintf(output,"%d",lcl->freq);
        break;
      case 5:
	if(lcl->option>=0)
	  sprintf(output,"%d",lcl->option);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbc_cont_cal_2_dbbc(buff,lcl)
char *buff;
struct dbbc_cont_cal_cmd *lcl;

{
  int ivalue;

  sprintf(buff,"cont_cal=");

  if(lcl->mode >= 0 && lcl->mode < NMODE_KEY) 
    strcat(buff,mode_key[lcl->mode]);

  if(lcl->polarity >= 0)
    sprintf(buff+strlen(buff),",%d",lcl->polarity);

  if(lcl->freq >= 0)
    sprintf(buff+strlen(buff),",%d",lcl->freq);

  if(lcl->option >= 0)
    sprintf(buff+strlen(buff),",%d",lcl->option);

  return;
}

int dbbc_2_dbbc_cont_cal(lclc,buff)
struct dbbc_cont_cal_cmd *lclc;
char *buff;
{
  char *ptr, ch;
  int i, ierr;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_key(ptr,mode_key,NMODE_KEY,&lclc->mode,-1,TRUE);
  if(ierr!=0)
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_int(ptr,&lclc->polarity,-1,TRUE);
  if(ierr!=0)
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_int(ptr,&lclc->freq,-1,TRUE);
  if(ierr!=0)
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_int(ptr,&lclc->option,-1,TRUE);
  if(ierr!=0)
    return -1;

  return 0;
}
