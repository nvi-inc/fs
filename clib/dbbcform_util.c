/* dbbcform buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/dbbcform_ds.h"

static char *mode_key[ ]={"astro","geo","wastro","test","lba"};
static char *test_key[ ]={"0","1","bin","tvg"};

#define NMODE_KEY sizeof(mode_key)/sizeof( char *)
#define NTEST_KEY sizeof(test_key)/sizeof( char *)

int dbbcform_dec(lcl,count,ptr)
struct dbbcform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    int idefault;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
	ierr=arg_key(ptr,mode_key,NMODE_KEY,&lcl->mode,0,FALSE);
        break;
      case 2:
	if(lcl->mode == 3)
	  ierr=arg_key(ptr,test_key,NTEST_KEY,&lcl->test,0,FALSE);
	else {
	  lcl->test=-1;
	  ierr=0;
	}
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbcform_enc(output,count,lcl)
char *output;
int *count;
struct dbbcform_cmd *lcl;
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
	if(lcl->mode == 3) {
	  ivalue = lcl->test;
	  if (ivalue >=0 && ivalue <NTEST_KEY)
	    strcpy(output,test_key[ivalue]);
	} else 
	  *count=-1;
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbcform_2_dbbc(buff,lcl)
char *buff;
struct dbbcform_cmd *lcl;

{
  int ivalue;

  sprintf(buff,"dbbcform=");

  if(lcl->mode >= 0 && lcl->mode < NMODE_KEY) 
    strcat(buff,mode_key[lcl->mode]);

  if(lcl->mode == 3) {
    strcat(buff,",");
    if(lcl->test >= 0 && lcl->test < NTEST_KEY) 
      strcat(buff,test_key[lcl->test]);
  }

  return;
}

int dbbc_2_dbbcform(lclc,buff)
struct dbbcform_cmd *lclc;
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

  if(lclc->mode == 3) {
    ptr=strtok(NULL,",");
    ierr=arg_key(ptr,test_key,NTEST_KEY,&lclc->test,-1,TRUE);
    if(ierr!=0)
    return -1;
  }

  return 0;
}
