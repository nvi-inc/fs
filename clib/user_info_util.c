/* S2 recorder user_info buffer parsing utilities */

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

static char *label_key[ ]={"field","label"};

#define LABEL_KEY sizeof(label_key)/sizeof( char *)

int user_info_dec(lcl,count,ptr)
struct user_info_parse *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_int(ptr,&lcl->field,0,FALSE);
      if(ierr==0 && (lcl->field<1 || lcl->field>5) )
	ierr=-200;
      break;
    case 2:
      ierr=arg_key(ptr,label_key,LABEL_KEY,&lcl->label,0,TRUE);
      break;
    case 3:
      len=strlen(ptr);
      len = len>sizeof(lcl->string)? sizeof(lcl->string) : len;
      memcpy(lcl->string,ptr,len);
      lcl->string[len]=0;
      break;
    case 4:
      if(strcmp(ptr,"auto")==0) {
	int len;
	char *space;
	if(lcl->field <1 || lcl->field>2 ||lcl->label 
	   ||strlen(lcl->string)!=0)
	  ierr=-200;
	else if (lcl->field==1) {
	  len=8;
	  memcpy(lcl->string,shm_addr->lnaant,len);
	} else if (lcl->field==2) {
	  len=10;
	  memcpy(lcl->string,shm_addr->lsorna,len);
	}
	space=memchr(lcl->string,' ',len);
	if(space==NULL)
	  lcl->string[len]=0;
	else
	  *space=0;
      } else if(strcmp(ptr,"literal")!=0 && strlen(ptr) > 0)
	ierr=-200;
      break;
    default:
      *count=-1;
      }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void user_info_enc(output,count,lcl)
char *output;
int *count;
struct user_info_cmd *lcl;
{
  int ind, ivalue, ivalue2;

  output=output+strlen(output);

  if(*count > 24 || *count < 1) {
    *count=-1;
  } else if(*count%3==1)
    sprintf(output,"%d",(*count+5)/6);
  else if(*count%6==2)
    strcpy(output,label_key[1]);
  else if(*count%6==5)
    strcpy(output,label_key[0]);
  else if(*count%6==3)
    strcpy(output,lcl->labels[*count/6]);
  else if(*count%6==0)
    switch (*count/6) {
    case 1:
      strcat(output,lcl->field1);
      break;
    case 2:
      strcat(output,lcl->field2);
      break;
    case 3:
      strcat(output,lcl->field3);
      break;
    case 4:
      strcat(output,lcl->field4);
      break;
    }
  
  if(*count>0)
    *count++;
  return;
}
