/* k4 recorder st buffer parsing utilities */

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

static char device[]={"d4"};           /* device menemonics */

static char *state_key[ ]={"play","record","stop","ejecting","ff","rewind",
                           "loading","no_tape" };

static char *state1_key[ ]={"off","on"};

#define STATE_KEY  sizeof(state_key)/sizeof( char *)
#define STATE1_KEY sizeof(state1_key)/sizeof( char *)

#define MAX_BUF 512

int k4st_dec(lcl,count,ptr)
struct k4st_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;
    static int old_speed;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,state1_key,STATE1_KEY,&lcl->record,0,FALSE);
      if (ierr !=0)
	ierr=arg_key(ptr,state_key,STATE_KEY,&lcl->record,1,TRUE);
      if (ierr == 0) {
	if (lcl->record < 0 || 1 < lcl->record)
	  ierr = -200;
      }
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4st_enc(output,count,lcl)
char *output;
int *count;
struct k4st_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = lcl->record;
    if (ivalue >=0 && ivalue <STATE_KEY)
      strcpy(output,state_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}

k4st_req_q(ip)
long ip[5];
{
 ib_req7(ip,device,10,"DRC?");
}

k4st_req_c(ip,lclc)
long ip[5];
struct k4st_cmd *lclc;
{
  if(lclc->record==1)
    ib_req2(ip,device,"REC");
  else
    ib_req2(ip,device,"PLY");
}

k4st_res_q(lclc,ip)
struct k4st_cmd *lclc;
long ip[5];
{
  char buffer[MAX_BUF];
  int max;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  if(strcmp(buffer,"DRC=PLY")==0)
    lclc->record=0;
  else if(strcmp(buffer,"DRC=REC")==0)
    lclc->record=1;
  else if((strcmp(buffer,"DRC=STP")==0 && shm_addr->equip.drive_type == K41) ||
	  (strcmp(buffer,"DRC=STOP")==0 && shm_addr->equip.drive_type == K42))
    lclc->record=2;
  else if(strcmp(buffer,"DRC=EJC")==0)
    lclc->record=3;
  else if(strcmp(buffer,"DRC=FF")==0)
    lclc->record=4;
  else if(strcmp(buffer,"DRC=REW")==0)
    lclc->record=5;
  else if(strcmp(buffer,"DRC=NULL")==0)
    lclc->record=6;
  else if(strcmp(buffer,"NULL")==0)
    lclc->record=7;
  else
    lclc->record=-1;
   
}
