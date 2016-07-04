/* holog buffer parsing utilities */

#include <stdio.h>
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

int holog_dec(lcl,count,ptr)
struct holog_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k;
    double freq;
    static int iconv, isb;
    static int itpis_save[MAX_ONOFF_DET];
    int itpis_test[MAX_ONOFF_DET];

    ierr=0;
    if(ptr==NULL) {
      ptr="";
    }

    switch (*count) {
    case 1:
      ierr=arg_float(ptr,&lcl->az,0.0,FALSE);
      if(ierr==0 && (-360.0 > lcl->az || lcl->az > 360.0))
	ierr=-200;
      else
	lcl->az*=DEG2RAD;
      break;
    case 2:
      ierr=arg_float(ptr,&lcl->el,0.0,FALSE);
      if(ierr==0 && (-90.0 > lcl->az || lcl->el > 90.0))
	ierr=-200;
      else
	lcl->el*=DEG2RAD;
      break;
    case 3:
      ierr=arg_int(ptr,&lcl->azp,0,FALSE);
      if(ierr==0 && (abs(lcl->azp) > 99 ||lcl->azp%2==0))
	ierr=-200;
      break;
    case 4:
      ierr=arg_int(ptr,&lcl->elp,0,FALSE);
      if(ierr==0 && (abs(lcl->elp) > 99 || lcl->elp%2==0))
	ierr=-200;
      break;
    case 5:
      if(strcmp(ptr,"off")==0) {
	lcl->ical=0;
      } else {
	ierr=arg_int(ptr,&lcl->ical,0,TRUE);
	if(ierr==0 && (lcl->ical < 0 || lcl->ical > 10000))
	  ierr=-200;
      }
      break;
    case 6:
      if(*ptr==0) {
	ierr=-106;
	return ierr;
      } else if (strlen(ptr) > 31) {
	ierr=-206;
	return ierr;
      } else {
	strncpy(lcl->proc,ptr,sizeof(lcl->proc));
      }
      break;
    case 7:
      ierr=arg_int(ptr,&lcl->wait,120,TRUE);
      if(ierr==0 && (lcl->wait < 0 || lcl->wait > 1000))
	ierr=-200;
      break;

    default:
      *count=-1;
    }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void holog_enc(output,count,lcl)
char *output;
int *count;
struct holog_cmd *lcl;
{
  int ivalue,i,j,k,lenstart,limit;
  static int inext;

  output=output+strlen(output);

    switch (*count) {
    case 1:
      sprintf(output+strlen(output),"%.3f",lcl->az*RAD2DEG);
      break;
    case 2:
      sprintf(output+strlen(output),"%.3f",lcl->el*RAD2DEG);
      break;
    case 3:
      sprintf(output+strlen(output),"%d",lcl->azp);
      break;
    case 4:
      sprintf(output+strlen(output),"%d",lcl->elp);
      break;
    case 5:
      if(lcl->ical <= 0) {
	strcat(output,"off");
      } else {
	sprintf(output+strlen(output),"%d",lcl->ical);
      }
      break;
    case 6:
      sprintf(output+strlen(output),"%s",lcl->proc);
      break;
    case 7:
      sprintf(output+strlen(output),"%d",lcl->wait);
      break;
    default:
      *count=-1;
    }

    if(*count>0) *count++;
    return;
}
