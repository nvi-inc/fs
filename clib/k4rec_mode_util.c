/* k4 rec_mode buffer parsing utilities */

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

static char *bw_key[ ]={"64","128","256"};

#define BW_KEY  sizeof(bw_key)/sizeof( char *)

#define MAX_BUF 512

int k4rec_mode_dec(lcl,count,ptr)
struct k4rec_mode_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,bw_key,BW_KEY,&lcl->bw,0,TRUE);
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4rec_mode_enc(output,count,lcl)
char *output;
int *count;
struct k4rec_mode_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = lcl->bw;
    if (ivalue >=0 && ivalue <BW_KEY)
      strcpy(output,bw_key[ivalue]);
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

k4rec_mode_req_q(ip)
long ip[5];
{
 ib_req7(ip,device,16,"SPM?");
 ib_req7(ip,device,16,"TSM?");
 ib_req7(ip,device,16,"DTS?");
}

k4rec_mode_req_c(ip,lclc)
long ip[5];
struct k4rec_mode_cmd *lclc;
{
  if(lclc->bw==1)
    ib_req2(ip,device,"SPM=16,1,128");
  else if(lclc->bw==2)
    ib_req2(ip,device,"SPM=16,1,256");
  else
    ib_req2(ip,device,"SPM=16,1,64");

  ib_req2(ip,device,"TSM=ON,FB,0");
  ib_req2(ip,device,"DTS=1,0");

}

k4rec_mode_res_q(lclc,ip)
struct k4rec_mode_cmd *lclc;
long ip[5];
{
  char buffer[MAX_BUF];
  int max;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  if(strcmp(buffer,"SPM=16,1,128")==0)
    lclc->bw=1;
  else if(strcmp(buffer,"SPM=16,1,256")==0)
    lclc->bw=2;
  else if(strcmp(buffer,"SPM=16,1,64")==0)
    lclc->bw=0;
  else
    lclc->bw=-1;
   
  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  if(strcmp(buffer,"TSM=ON,FB,0")!=0)
    lclc->bw=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  if(strcmp(buffer,"DTS=1")!=0)
    lclc->bw=-1;
}

