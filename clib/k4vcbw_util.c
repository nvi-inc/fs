/* k4 VC BW buffer parsing utilities */

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

static char deviceC[]={"v4"};           /* device menemonics */
static char deviceB[]={"vb"};           /* device menemonics */
static char deviceA[]={"va"};           /* device menemonics */

static char *bw1_key[ ]={"2","4"};
static char *bw2_key[ ]={"2","32"};
static char *bw2a_key[ ]={"2","16"};
static char *bw2b_key[ ]={"8","16"};

#define NBW1_KEY sizeof(bw1_key)/sizeof( char *)
#define NBW2_KEY sizeof(bw2_key)/sizeof( char *)
#define NBW2A_KEY sizeof(bw2a_key)/sizeof( char *)
#define NBW2B_KEY sizeof(bw2b_key)/sizeof( char *)

#define MAX_BUF 512

int k4vcbw_dec(lcl,count,ptr,itask)
struct k4vcbw_cmd *lcl;
int *count,itask;
char *ptr;
{
    int ierr, arg_int();
    int type, ipos;

    ierr=0;
    if(ptr == NULL) ptr="";

    ipos=0;
    if(itask==2)
      ipos=1;

    switch (*count) {
    case 1:
      type=shm_addr->equip.rack_type;
      if(itask==3)
	ierr=arg_key_flt(ptr,bw1_key,NBW1_KEY,&lcl->bw[ipos],0,TRUE);
      else if(type == K42 || type == K42K3 || type == K42MK4 )
	ierr=arg_key_flt(ptr,bw2_key,NBW2_KEY,&lcl->bw[ipos],0,TRUE);
      else if(type == K42A || type == K42AK3 || type == K42AMK4 )
	ierr=arg_key_flt(ptr,bw2a_key,NBW2A_KEY,&lcl->bw[ipos],0,TRUE);
      else if(type == K42BU || type == K42BUK3 || type == K42BUMK4 )
	ierr=arg_key_flt(ptr,bw2b_key,NBW2B_KEY,&lcl->bw[ipos],0,TRUE);
      break;
    default:
      *count=-1;
    }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4vcbw_enc(output,count,lcl,itask)
char *output;
int *count, itask;
struct k4vcbw_cmd *lcl;
{
  int ivalue, type, ipos;

  output=output+strlen(output);

  ipos=0;
  if(itask==2)
    ipos=1;

  switch (*count) {
  case 1:
    ivalue = lcl->bw[ipos];
    type=shm_addr->equip.rack_type;
    if(itask==3)
      if (ivalue >=0 && ivalue <NBW1_KEY)
	strcpy(output,bw1_key[ivalue]);
      else
	strcpy(output,BAD_VALUE);
    else if(type == K42 || type == K42K3 || type == K42MK4 )
      if (ivalue >=0 && ivalue <NBW2_KEY)
	strcpy(output,bw2_key[ivalue]);
      else
	strcpy(output,BAD_VALUE);
    else if(type == K42A || type == K42AK3 || type == K42AMK4 )
      if (ivalue >=0 && ivalue <NBW2A_KEY)
	strcpy(output,bw2a_key[ivalue]);
      else
	strcpy(output,BAD_VALUE);
    else if(type == K42BU || type == K42BUK3 || type == K42BUMK4 )
      if (ivalue >=0 && ivalue <NBW2B_KEY)
	strcpy(output,bw2b_key[ivalue]);
      else
	strcpy(output,BAD_VALUE);
    break;
  default:
    *count=-1;
  }

}

k4vcbw_req_q(ip,itask)
long ip[5];
int itask;
{
 char *device;
 int lenrd;

 switch (itask) {
 case 1:
   device=deviceA;
   lenrd=7*8+3+6*8+17;
   break;
 case 2:
   device=deviceB;
   lenrd=7*8+3+6*8+17;
   break;
 case 3:
   device=deviceC;
   lenrd=13*16+2;
   break;
 default:
   device="  ";
   lenrd=210;
 }

 ib_req7(ip,device,lenrd,"RD");

}
k4vcbw_req_c(ip,lclc,itask)
long ip[5];
struct k4vcbw_cmd *lclc;
int itask;
{
  char buffer[30];
  char *device;
  int ipos;

 switch (itask) {
 case 1:
   device=deviceA;
   break;
 case 2:
   device=deviceB;
   break;
 case 3:
   device=deviceC;
   break;
 default:
   device="  ";
 }

  ipos=0;
  if(itask==2)
    ipos=1;

  if(itask == 3)
    if(lclc->bw[ipos]==1)
      strcpy(buffer,"BW4");
    else
      strcpy(buffer,"BW2");
  else
    if(lclc->bw[ipos]==1)
      strcpy(buffer,"BW32");
    else
      strcpy(buffer,"BW2");

  ib_req2(ip,device,buffer);

}

k4vcbw_res_q(lclc,ip,itask)
struct k4vcbw_cmd *lclc;
long ip[5];
int itask;
{
  char buffer[MAX_BUF];
  int max,i;
  int icount;
  char lohi, loup;
  int ipos;

  ipos=0;
  if(itask==2)
    ipos=1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }

  if(itask==3) 
    if(buffer[8*16+29]=='2')
      lclc->bw[ipos]=0;
    else if(buffer[8*16+29]=='4')
      lclc->bw[ipos]=1;
    else
      lclc->bw[ipos]=-1;
  else
    if(buffer[7*8+3+6*8+2]=='0')
      lclc->bw[ipos]=0;
    else if(buffer[7*8+3+6*8+2]=='3')
      lclc->bw[ipos]=1;
    else
      lclc->bw[ipos]=-1;

}


