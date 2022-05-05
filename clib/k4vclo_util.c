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
/* k4 VC LO buffer parsing utilities */

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

static char deviceC[]={"l4"};           /* device menemonics */
static char deviceA[]={"la"};           /* device menemonics */
static char deviceB[]={"lb"};           /* device menemonics */

#define MAX_BUF 512

int k4vclo_dec(lcl,ivc,count,ptr,itask)
struct k4vclo_cmd *lcl;
int *ivc,*count,itask;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    double atof();
    char buffer[80];
    int ilen, flen, ipos;
    char *decloc, *fract;
    int freq, ifreq, ffreq;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_int(ptr,ivc,0,FALSE);
      if(ierr==0 && (*ivc <1 || (*ivc >16 && itask == 3) ||
		     (*ivc > 8 && itask != 3)))
	ierr=-200;
      break;
    case 2:
      if(ptr == NULL || *ptr == '\0') {
	ierr=-100;
	break;
      }
      ipos=*ivc-1;
      if(itask==2)
	ipos+=8;
      if (strcmp(ptr,"*")!=0) {
	decloc = strchr(ptr,'.');
	if (decloc != NULL) {
	  flen = strlen(decloc)-1;
	  fract = ++decloc;
	  ilen = decloc-ptr;
	} else {
	  fract=NULL;
	  flen=0;
	  ilen=strlen(ptr);
	}
       
	if(ilen>0) {
	  strncpy(buffer,ptr,ilen);
	  buffer[ilen]=0;
	  ifreq = atoi(buffer)*100;
	} else
	  ifreq=0;

	if(flen>0) {
	  strncpy(buffer,fract,flen);
	  buffer[flen]=0;
	  ffreq = atoi(buffer);
	  if (flen == 1)
	    ffreq *= 10;
	} else
	  ffreq=0;

	freq = ifreq+ffreq;
      } else
	freq=lcl->freq[ipos];

      if ((freq < 9999 || freq > 51199) && itask == 3)
	ierr = -200;
      else if ((freq < 49999 || freq > 99999) && itask != 3)
	ierr = -200;
      else
	lcl->freq[ipos] = freq;
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4vclo_enc(output,count,lcl,itask)
char *output;
int *count,itask;
struct k4vclo_cmd *lcl;
{
  int ivalue;

  output=output+strlen(output);

  if(*count > 0 && (( *count < 17 && itask == 3) ||
		    (*count <9 && itask != 3))) {
    int ipos=*count-1;
    if(itask==2)
      ipos+=8;
    sprintf(output,"%02d,%06.2f",*count,(float)lcl->freq[ipos]/100);
  } else
    *count=-1;
  
  return;
}
void k4vclo_mon(output,count,lcl,itask)
char *output;
int *count,itask;
struct k4vclo_mon *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  if(*count > 0 && ((*count < 17 && itask == 3)|| (*count <9 && itask != 3))) {
    int ipos=*count-1;
    if(itask==2)
      ipos+=8;
    if(lcl->yes[ipos])
      strcpy(output,"yes");
    else
      strcpy(output,"no");
    
    strcat(output,",");
    if(lcl->lock[ipos])
      strcat(output,"locked");
    else
      strcat(output,"unlocked");
  } else
    *count=-1;

  return;
}

k4vclo_req_q(ip,itask)
int ip[5];
int itask;
{
 char *device;
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
    
 ib_req7(ip,device,13*16+2,"RD");
}

k4vclo_req_c(ip,lclc,ivc,itask)
int ip[5];
struct k4vclo_cmd *lclc;
int ivc,itask;
{
  char buffer[20];
  char *device;

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
    
    sprintf(buffer,"FR%-06.2fMZ",(float)lclc->freq[ivc-1]/100);
    ib_req2(ip,device,buffer);
  } else {
    int ipos=ivc-1;
    if(itask==2)
      ipos+=8;
    sprintf(buffer,"FRQ=%02d,%-06.2f",ivc,(float)lclc->freq[ipos]/100);
    ib_req2(ip,device,buffer);
  }

}

k4vclo_res_q(lclc,lclm,ip,itask)
struct k4vclo_cmd *lclc;
struct k4vclo_mon *lclm;
int ip[5];
int itask;
{
  char buffer[MAX_BUF];
  int max,i;
  float freq;
  int icount,ioff,n,iend;

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
    if(3!=sscanf(buffer+13*i+4,"%c%c%6f",
		 lclm->yes+n,lclm->lock+n,&freq)) {
      ip[2]=-1;
      return;
    }
    if(index("YN",lclm->yes[n])==NULL || lclm->yes[n]==0) {
      ip[2]=-1;
      return;
    }
    if(index("LUX",lclm->lock[n])==NULL || lclm->lock[n]==0) {
      ip[2]=-1;
      return;
    }
    if(((freq <99.989 || freq > 511.991) && itask == 3) ||
       ((freq <499.989 || freq > 999.991) && itask != 3)) {
      ip[2]=-1;
      return;
    }
    lclc->freq[n]=freq*100+.5;
  }
  
}
