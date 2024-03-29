/*
 * Copyright (c) 2020-2021, 2023 NVI, Inc.
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
/* dbbc3 bbcnn buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *if_key[ ]={ "a", "b", "c", "d", "e", "f", "g", "h" };
                                                         /* if input source */
static char *bw_key[ ]={"0","2","4","8","16","32","64","128"};
static char *agc_key[ ]={"man","agc"};

#define NIF_KEY sizeof(if_key)/sizeof( char *)
#define NBW_KEY sizeof(bw_key)/sizeof( char *)
#define NAGC_KEY sizeof(agc_key)/sizeof( char *)

static int dbbc3_freq(unsigned int *,char *);
static void perform_swaps(struct dbbc3_bbcnn_mon *);
char *getenv_DBBC3( char *env, int *actual, int *nominal, int *error, int options);

int dbbc3_bbcnn_dec(lcl,count,ptr,itask)
struct dbbc3_bbcnn_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    int i, idefault;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
	if(strcmp(ptr,"*")==0)
	  break;
        if(ptr == NULL || *ptr == '\0') {
          ierr=-100;
          break;
        }

	if(dbbc3_freq(&lcl->freq,ptr) != 0) {
	  ierr=-200;
	  break;
	}
	if (lcl->freq > 4096000000ul)
	  ierr = -200;
        break;
      case 2:
        idefault=(itask-1)%64/8;
        ierr=arg_key(ptr,if_key,NIF_KEY,&lcl->source,idefault,TRUE);
	if(ierr==0 && lcl->source >= shm_addr->dbbc3_ddc_ifs)
	  ierr=-300;
        break;
      case 3:
	ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&lcl->bw,5,TRUE);
    if(0 == ierr && 0 == lcl->bw)
        ierr=-200;
        break;
      case 4:
        ierr=arg_int(ptr,&lcl->avper,1,TRUE);
	if(ierr == 0 && (lcl->avper <= 0 || lcl->avper > 60))
	  ierr=-200;
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbc3_bbcnn_enc(output,count,lcl)
char *output;
int *count;
struct dbbc3_bbcnn_cmd *lcl;
{
    int ind, ivalue, whole, fract;

    output=output+strlen(output);

    switch (*count) {
      case 1:
	whole=lcl->freq/1000000;
	fract=lcl->freq-whole*1000000l;
        sprintf(output,"%4d.%06d",whole,fract);
        break;
      case 2:
        ivalue = lcl->source;
        if (ivalue >=0 && ivalue <NIF_KEY)
          strcpy(output,if_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
        ivalue = lcl->bw;
        if (ivalue >=0 && ivalue <NBW_KEY)
          sprintf(output,"%2s",bw_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 4:
	sprintf(output,"%2d",lcl->avper);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbc3_bbcnn_mon(output,count,lcl)
char *output;
int *count;
struct dbbc3_bbcnn_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        if(lcl->agc==0) strcpy(output,"man");
        else if(lcl->agc==1) strcpy(output,"agc");
        break;
      case 2:
      case 3:
        ind=*count-2;
        sprintf(output,"%3u",lcl->gain[ind]);
        break;
      case 4:
      case 5:
        ind=*count-4;
        sprintf(output,"%5u",lcl->tpon[ind]);
        break;
      case 6:
      case 7:
        ind=*count-6;
        sprintf(output,"%5u",lcl->tpoff[ind]);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void bbcnn_2_dbbc3(buff,itask,lcl)
char *buff;
int itask;
struct dbbc3_bbcnn_cmd *lcl;

{
  int whole, fract, ivalue;

  whole=lcl->freq/1000000;
  fract=lcl->freq-whole*1000000l;
  sprintf(buff,"dbbc%03d=%d.%06d,",itask,whole,fract);

  ivalue = lcl->source;
  if (ivalue >=0 && ivalue <NIF_KEY) /*null if not a valid value*/
    strcat(buff,if_key[ivalue]);
  strcat(buff,",");  

  ivalue = lcl->bw;
  if (ivalue >=0 && ivalue <NBW_KEY)
    strcat(buff,bw_key[ivalue]);
  strcat(buff,",");  

  sprintf(buff+strlen(buff),"%d",lcl->avper);

  return;
}

int dbbc3_2_bbcnn(lclc,lclm,buff)
struct dbbc3_bbcnn_cmd *lclc;
struct dbbc3_bbcnn_mon *lclm;
char *buff;
{
  char *ptr, ch;
  int i, ierr;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(dbbc3_freq(&lclc->freq,ptr) != 0)
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL || strlen(ptr)!= 1)
    return -1;
  ptr[0]=tolower(ptr[0]);
  ierr=arg_key(ptr,if_key,NIF_KEY,&lclc->source,0,FALSE);
  if(ierr!=0 || 0==strcmp(ptr,"*"))
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&lclc->bw,0,FALSE);
  if(ierr!=0 || 0==strcmp(ptr,"*"))
    return -1;

  ptr=strtok(NULL,",");
  lclc->avper=-1;
  if(1!=sscanf(ptr,"%d%c",&lclc->avper,&ch))
    return -1;

  ptr=strtok(NULL,",");
  ierr=arg_key(ptr,agc_key,NAGC_KEY,&lclm->agc,0,FALSE);
  if(ierr!=0 || 0==strcmp(ptr,"*"))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d%c",lclm->gain+0,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d%c",lclm->gain+1,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",lclm->tpon+0,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",lclm->tpon+1,&ch))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",lclm->tpoff+0,&ch))
    return -1;

  ptr=strtok(NULL,",;");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",lclm->tpoff+1,&ch))
    return -1;

  perform_swaps(lclm);
  return 0;
}
static int dbbc3_freq(pulFreq,sptr)
unsigned int *pulFreq;
char *sptr;
{
  int start, decpt, outw, outf, len, i, j, iwhole, ifract;
  char whole[5],fract[7]; /* just big enough with trailing null */

  start=1;
  decpt=0;
  outw=0;
  outf=0;
  len=strlen(sptr);
  for (i=0;i<len;i++) {
    if(start && sptr[i]==' ')  /* leading spaces: skip */
      continue;
    start=0;                  /* not spaces anymore */
    if(sptr[i]=='.') {         /* decimal point */
      if(decpt) {
	return -1;            /* only one allowed */
      } else {
	decpt=1;
	continue;
      }
    }
    if(sptr[i]==' ')           /* more spaces, only trailing allowed now */
      for(j=i+1;j<len;j++)
	if(sptr[j]!=' ') {
	  return -1;
	}
    if(NULL==strchr("0123456789",sptr[i])) { /* must be numeric */
      return -1;
    }
    if(!decpt) {             /* the part before the decimal */
      if(outw+2>sizeof(whole)) {
	return -1;
      }
      whole[outw++]=sptr[i];
    } else {                 /* the part after */
      if(outf+2>sizeof(fract)) {
	return -1;
      }
      fract[outf++]=sptr[i];
    }
  }
  whole[outw]=0;       
  fract[outf]=0;
  if(outw==0 && outf==0) { /*nothing there*/
    return -1;
  }
 
  iwhole=0;
  ifract=0;
  if(outw!=0)
    if(1!=sscanf(whole,"%d",&iwhole)) {
      return -1;
    }
  if(outf!=0)
    if(1!=sscanf(fract,"%d",&ifract)) {
      return -1;
    }
  for(i=0;i<(6-outf);i++)
    ifract*=10;

  *pulFreq=((unsigned int ) iwhole)*1000000+ifract;

  return 0;
}
static void perform_swaps( lclm)
struct dbbc3_bbcnn_mon *lclm;
{
  static int tpi_ul = -1;
  static int gain_ul = -1;
  static int tpi_onoff = -1;
  char *ptr;

  if(0>tpi_ul) {
    int actual, error;
    ptr=getenv_DBBC3("FS_DBBC3_BBCNNN_TPI_USB_LSB_SWAP",&actual,NULL,&error,1);
    if(0==error)
      tpi_ul=actual;
    else
      tpi_ul=0;
  }
  if (tpi_ul) {
    unsigned int temp_uint;

    temp_uint=lclm->tpoff[1];
    lclm->tpoff[1]=lclm->tpoff[0];
    lclm->tpoff[0]=temp_uint;

    temp_uint=lclm->tpon[1];
    lclm->tpon[1]=lclm->tpon[0];
    lclm->tpon[0]=temp_uint;
  }

  if(0>gain_ul) {
    int actual, error;
    ptr=getenv_DBBC3("FS_DBBC3_BBCNNN_GAIN_USB_LSB_SWAP",&actual,NULL,&error,1);
    if(0==error)
      gain_ul=actual;
    else
      gain_ul=0;
  }
  if (gain_ul) {
    int temp_int;

    temp_int=lclm->gain[1];
    lclm->gain[1]=lclm->gain[0];
    lclm->gain[0]=temp_int;
  }

  if(0>tpi_onoff) {
    int actual, error;
    ptr=getenv_DBBC3("FS_DBBC3_BBCNNN_ON_OFF_SWAP",&actual,NULL,&error,1);
    if(0==error)
      tpi_onoff=actual;
    else
      tpi_onoff=0;
  }
  if (tpi_onoff) {
    unsigned int temp_uint;

    temp_uint=lclm->tpoff[1];
    lclm->tpoff[1]=lclm->tpon[1];
    lclm->tpon[1]=temp_uint;

    temp_uint=lclm->tpoff[0];
    lclm->tpoff[0]=lclm->tpon[0];
    lclm->tpon[0]=temp_uint;
  }
  return;
}
