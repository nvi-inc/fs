/* satellite buffer parsing utilities */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *key_mode[ ]={ "track"  , "radc"  , "azel"};
static char *key_wrap[ ]={ "neutral"  , "ccw"  , "cw"};

#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_WRAP sizeof(key_wrap)/sizeof( char *)

int satellite_dec(lcl,count,ptr)
struct satellite_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k;
    double freq;

    ierr=0;
    if(ptr==NULL) {
      ptr="";
    }

    switch (*count) {
    case 1:
      if(ptr==NULL || *ptr==0) {
	lcl->name[0]=0;
      } else if (1+strlen(ptr) > sizeof(lcl->name)) {
	ierr=-200;
	break;
      } else if(0!=strcmp(ptr,"*")) {
        int i;
	strncpy(lcl->name,ptr,sizeof(lcl->name));
	for (i=0;i<strlen(lcl->name);i++)
	  lcl->name[i]=toupper(lcl->name[i]);
	for(i=strlen(lcl->name)-1;-1<i;i--)
	  if(lcl->name[i]!=' '
	     && lcl->name[i]!='\t'
	     && lcl->name[i]!='\r')
	    break;
	  else
	    lcl->name[i]=0;
      }
      break;
    case 2:
      if(ptr==NULL || *ptr==0) {
	if(lcl->name[0]==0)
	  lcl->tlefile[0]=0;
	else {
	  ierr=-100;
	  break;
	}
      } else if(lcl->name[0]==0) {
	ierr=-100;
	break;
      } else if (1+strlen(ptr) > sizeof(lcl->tlefile)) {
	ierr=-202;
	break;
      } else if(0!=strcmp(ptr,"*")) {
	strncpy(lcl->tlefile,ptr,sizeof(lcl->tlefile));
      }
      break;
    case 3:
      ierr=arg_key(ptr,key_mode,NKEY_MODE,&lcl->mode,0,TRUE);
      break;
    case 4:
      ierr=arg_key(ptr,key_wrap,NKEY_WRAP,&lcl->wrap,0,TRUE);
      break;
    default:
      *count=-1;
    }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void satellite_enc(output,count,lcl)
char *output;
int *count;
struct satellite_cmd *lcl;
{
  int ivalue,i,j,k,lenstart,limit;
  static int inext;

  output=output+strlen(output);

    switch (*count) {
    case 1:
      sprintf(output+strlen(output),"%s",lcl->name);
      break;
    case 2:
      sprintf(output+strlen(output),"%s",lcl->tlefile);
      break;
    case 3:
      ivalue=lcl->mode;
      if(ivalue>=0 && ivalue <NKEY_MODE)
	strcpy(output,key_mode[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    case 4:
      ivalue=lcl->wrap;
      if(ivalue>=0 && ivalue <NKEY_WRAP)
	strcpy(output,key_wrap[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    default:
      *count=-1;
    }

    if(*count>0) *count++;
    return;
}
