/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* k4 VC buffer parsing utilities */

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
static char deviceA[]={"va"};           /* device menemonics */
static char deviceB[]={"vb"};           /* device menemonics */

static char *key_lohi[ ]={ "low", "high" };
static char *key_loup[ ]={ "lsb", "usb" };

#define NKEY_LOHI sizeof(key_lohi)/sizeof( char *)
#define NKEY_LOUP sizeof(key_loup)/sizeof( char *)

#define MAX_BUF 512

int k4vc_dec(lcl,ivc,count,ptr,itask)
struct k4vc_cmd *lcl;
int *ivc,*count,itask;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    double atof();
    char buffer[80];
    int ilen, flen;
    char *decloc, *fract;
    int idfok,idf;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_int(ptr,ivc,0,FALSE);
      if(ierr==0 && (*ivc <1 || ((*ivc >16 && itask ==3) ||
				 (*ivc>8 && itask !=3))))
	ierr=-200;
      break;
    case 2:
      if(itask!=3) {
	int ipos=*ivc-1;
	if(itask==2)
	  ipos+=8;
	ierr=arg_int(ptr,&lcl->att[ipos],0,TRUE);
	if(ierr==0 && (lcl->att[ipos] <0 || lcl->att[ipos] >15))
	  ierr=-200;
      } else {
	if(shm_addr->k4vclo.freq[*ivc-1]!=0) {
	  idfok=TRUE;
	  if(shm_addr->k4vclo.freq[*ivc-1]>=24000)
	    idf=1;
	  else
	    idf=0;
	} else
	  idfok=FALSE;
	ierr=arg_key(ptr,key_lohi,NKEY_LOHI,&lcl->lohi[*ivc-1],idf,idfok);
      }
      break;
    case 3:
      {
	int ipos=*ivc-1;
	if(itask==2)
	  ipos+=8;
	ierr=arg_key(ptr,key_loup,NKEY_LOUP,&lcl->loup[ipos],1,TRUE);
	break;
      }
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4vc_enc(output,count,lcl,itask)
char *output;
int *count,itask;
struct k4vc_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);

  if(*count > 0 && ((*count < 17 && itask ==3) ||
		    (*count < 9 && itask !=3))) {
    int ipos=*count-1;
    if(itask==2)
      ipos+=8;

    sprintf(output,"%02d,",*count);
    if(itask != 3) {
      output+=strlen(output);
      sprintf(output,"%02d",lcl->att[ipos]);
    } else {
      ivalue=lcl->lohi[ ipos];
      if(ivalue>=0 && ivalue <NKEY_LOHI)
	strcat(output,key_lohi[ivalue]);
      else
	strcat(output,BAD_VALUE);
    }

    strcat(output,",");
    ivalue=lcl->loup[ ipos];
    if(ivalue>=0 && ivalue <NKEY_LOUP)
      strcat(output,key_loup[ivalue]);
    else
      strcat(output,BAD_VALUE);

  } else
    *count=-1;
  
  return;
}
void k4vc_mon(output,count,lcl,itask)
char *output;
int *count,itask;
struct k4vc_mon *lcl;
{
  int ivalue, pwr;

  output=output+strlen(output);
  
  if(*count > 0 && ((*count < 17 && itask ==3) ||
		    (*count < 9 && itask !=3))) {
    int ipos=*count-1;
    if(itask==2)
      ipos+=8;
    if(lcl->yes[ipos])
      strcpy(output,"yes");
    else
      strcpy(output,"no");
    
    strcat(output,",");
    pwr=lcl->usbpwr[ipos];
    if(pwr>= 0 && pwr <= 99)
      sprintf(output+strlen(output),"%02d",pwr);
    else
      strcat(output,BAD_VALUE);

    strcat(output,",");
    pwr=lcl->lsbpwr[ipos];
    if(pwr>= 0 && pwr <= 99)
      sprintf(output+strlen(output),"%02d",pwr);
    else
      strcat(output,BAD_VALUE);
  } else
    *count=-1;

  return;
}

k4vc_req_q(ip,itask)
int ip[5];
int itask;
{
 char *device;
 int lenrd, lenlv;

 switch (itask) {
 case 1:
   device=deviceA;
   lenlv=74;
   lenrd=125;
   break;
 case 2:
   device=deviceB;
   lenlv=74;
   lenrd=125;
   break;
 case 3:
   device=deviceC;
   lenlv=9*16+2;
   lenrd=13*16+2;
   break;
 default:
   device="  ";
   lenlv=74;
   lenrd=124;
 }

 ib_req7(ip,device,lenrd,"RD");

 ib_req7(ip,device,lenlv,"LV");

}

k4vc_req_c(ip,lclc,ivc,itask)
int ip[5];
struct k4vc_cmd *lclc;
int ivc,itask;
{
  char buffer[20];
  char *device;

  int ipos=ivc-1;
  if(itask==2)
    ipos+=8;

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

  if(itask==3) {
    sprintf(buffer,"CH%02d",ivc);
    ib_req2(ip,device,buffer);
  
    if(lclc->lohi[ivc-1])
      strcpy(buffer,"HIF");
    else
      strcpy(buffer,"LIF");
    ib_req2(ip,device,buffer);
  } else {
    sprintf(buffer,"AT%02d-%02d",ivc,lclc->att[ipos]);
    ib_req2(ip,device,buffer);
  }

  if(lclc->loup[ipos])
    strcpy(buffer,"USB");
  else
    strcpy(buffer,"LSB");
  ib_req2(ip,device,buffer);

}

k4vc_res_q(lclc,lclm,ip,itask)
struct k4vc_cmd *lclc;
struct k4vc_mon *lclm;
int ip[5];
int itask;
{
  char buffer[MAX_BUF];
  int max,i;
  int icount, iend,ioff,n;
  char lohi, loup;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }

  if(itask==2)
    ioff=8;
  else
    ioff=0;

  if(itask==3)
    iend=16;
  else
    iend=8;

  for(i=0;i<iend;i++) {
    n=i+ioff;
    if(itask==3) {
      if(3!=(icount=sscanf(buffer+8*i+4,"%c%c%c",
			   lclm->yes+n,&lohi,&loup))) {
	ip[2]=-1;
	return;
      }
    } else {
      if(2!=(icount=sscanf(buffer+7*i+4,"%c%c",
			   lclm->yes+n,&loup))) {
	ip[2]=-1;
	return;
      }
    }

    if(index("YN",lclm->yes[n])==NULL || lclm->yes[n]==0) {
      ip[2]=-1;
      return;
    }

    if(itask==3) {
      if(index("LH",lohi)==NULL || lohi==0) {
	ip[2]=-1;
	return;
      } else if(lohi == 'H')
	lclc->lohi[n]=1;
      else
	lclc->lohi[n]=0;
    }

    if(index("LU",loup)==NULL || loup==0) {
      ip[2]=-1;
      return;
    } else if(loup == 'U')
      lclc->loup[n]=1;
    else
      lclc->loup[n]=0;
    

    if(itask!=3) {
      if(1!=(icount=sscanf(buffer+59+6*i+3,"%2d",
			   lclc->att+n))) {
	ip[2]=-1;
	return;
      }
    }
  }

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-2;
    return;
  }
    
  for(i=0;i<iend;i++) {
    n=i+ioff;
    if(2!=sscanf(buffer+9*i+3,"%2d/%2d",
		 lclm->usbpwr+n,lclm->lsbpwr+n)) {
      ip[2]=-2;
      return;
    }
  }

}
