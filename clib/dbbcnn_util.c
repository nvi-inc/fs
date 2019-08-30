/* dbbcnn buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *if_key[ ]={ "a", "b", "c", "d" }; /* if input source */
static char *bw_key[ ]={"1","2","4","8","16","32","64"};
static char *agc_key[ ]={"man","agc"};

#define NIF_KEY sizeof(if_key)/sizeof( char *)
#define NBW_KEY sizeof(bw_key)/sizeof( char *)
#define NAGC_KEY sizeof(agc_key)/sizeof( char *)

static int dbbc_freq(unsigned long *,char *);

int dbbcnn_dec(lcl,count,ptr,itask)
struct dbbcnn_cmd *lcl;
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

	if(dbbc_freq(&lcl->freq,ptr) != 0) {
	  ierr=-200;
	  break;
	}
	if (lcl->freq < 1 || lcl->freq > 2200000000ul)
	  ierr = -200;
        break;
      case 2:
	if(itask <= 4)
	  idefault = 0;
	else if (itask <= 9)
	  idefault = 1;
	else if (itask <= 12)
	  idefault = 2;
	else
	  idefault = 3;
        ierr=arg_key(ptr,if_key,NIF_KEY,&lcl->source,idefault,TRUE);
	if(ierr==0 && lcl->source >= shm_addr->dbbc_cond_mods)
	  ierr=-300;
        break;
      case 3:
	ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&lcl->bw,3,TRUE);
	if(0 == ierr) 
	  if(0==lcl->bw && shm_addr->dbbcddcvl[0] != ' ')
	    ierr=-210;
	  else if(5==lcl->bw && NULL == index("ef",shm_addr->dbbcddcvl[0]) &&
		  shm_addr->dbbcddcv < 107)
	    ierr=-220;
	  else if(6==lcl->bw && shm_addr->dbbcddcv < 107)
	    ierr=-230;
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

void dbbcnn_enc(output,count,lcl)
char *output;
int *count;
struct dbbcnn_cmd *lcl;
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

void dbbcnn_mon(output,count,lcl)
char *output;
int *count;
struct dbbcnn_mon *lcl;
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

void dbbcnn_2_dbbc(buff,itask,lcl)
char *buff;
int itask;
struct dbbcnn_cmd *lcl;

{
  int whole, fract, ivalue;

  whole=lcl->freq/1000000;
  fract=lcl->freq-whole*1000000l;
  sprintf(buff,"dbbc%02d=%d.%06d,",itask,whole,fract);

  ivalue = lcl->source;
  if (ivalue >=0 && ivalue <NIF_KEY) /*null if not a valid value*/
    strcat(buff,if_key[ivalue]);
  strcat(buff,",");  

  ivalue = lcl->bw;
  if (ivalue >=0 && ivalue <NBW_KEY)
    strcat(buff,bw_key[ivalue]);
  strcat(buff,",");  

  if(shm_addr->dbbcddcv<101) {
    ivalue = lcl->bw;
    if (ivalue >=0 && ivalue <NBW_KEY)
      strcat(buff,bw_key[ivalue]);
    strcat(buff,",");  
  }

  sprintf(buff+strlen(buff),"%d",lcl->avper);

  return;
}

int dbbc_2_dbbcnn(lclc,lclm,buff)
struct dbbcnn_cmd *lclc;
struct dbbcnn_mon *lclm;
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
  if(dbbc_freq(&lclc->freq,ptr) != 0)
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

  if(shm_addr->dbbcddcv<101) {
    int bw;
    ptr=strtok(NULL,",");
    ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&bw,0,FALSE);
    if(ierr!=0 || 0==strcmp(ptr,"*"))
      return -1;
    if(bw!=lclc->bw)
      lclc->bw=-1;
  }

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

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%u%c",lclm->tpoff+1,&ch))
    return -1;

  return 0;
}
static int dbbc_freq(pulFreq,sptr)
unsigned long *pulFreq;
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

  *pulFreq=((long unsigned) iwhole)*1000000+ifract;

  return 0;
}
