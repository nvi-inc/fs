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

static char device[]={"r1"};           /* device menemonics */

static char *bw_key[ ]={"16","32","64","128","256"};
static char *bt_key[ ]={"1","2","4","8"};
static char *ch_key[ ]={"1","2","4","8","16"};
static char *fm_key[ ]={"OLD","NEW"};
static char *ts_key[ ]={"ON","OFF"};
static char *im_key[ ]={"FT","FB"};

#define BW_KEY  sizeof(bw_key)/sizeof( char *)
#define BT_KEY  sizeof(bt_key)/sizeof( char *)
#define CH_KEY  sizeof(ch_key)/sizeof( char *)
#define FM_KEY  sizeof(fm_key)/sizeof( char *)
#define TS_KEY  sizeof(ts_key)/sizeof( char *)
#define IM_KEY  sizeof(im_key)/sizeof( char *)

#define MAX_BUF 512

int k4rec_mode_dec(lclc,count,ptr)
struct k4rec_mode_cmd *lclc;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int len;

    int i;

/* The following parameters are default values for each total data rate */
/* of DFC-2100.  From left to right, 16, 32, 64, 128, and 256 MHz,      */
/* respectively.  See *bt_key, *ch_key, and *im_key*, respectively.     */
    static int bt_default[]={ 0,  0,  0,  0,  0};
    static int ch_default[]={ 4,  4,  4,  4,  4};
    static int im_default[]={ 0,  0,  0,  0,  1};
    static int nm_default[]={ 0,  0,  0, 15, 30};

    int dbw, dbt, dch, dim, dnm;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key_flt(ptr,bw_key,BW_KEY,&lclc->bw,3,TRUE);
      dbw=lclc->bw;
      break;
    case 2:
      dbt=bt_default[dbw];
      ierr=arg_key(ptr,bt_key,BT_KEY,&lclc->bt,dbt,TRUE);
      break;
    case 3:
      dch=ch_default[dbw];
      ierr=arg_key(ptr,ch_key,CH_KEY,&lclc->ch,dch,TRUE);
      break;
    case 4:
      if(strlen(ptr) != 0) {   /* Time stamp mode, either FT or FB */
        int ilen=strlen(ptr);
        for (i=0;i<ilen;i++)
        ptr[i]=toupper(ptr[i]);
      }
      dim=im_default[dbw];
      ierr=arg_key(ptr,im_key,IM_KEY,&lclc->im,dim,TRUE);
      break;
    case 5:
      dnm=nm_default[dbw];
      ierr=arg_int(ptr,&lclc->nm,dnm,TRUE);
      if ((lclc->nm < 0 || lclc->nm > 30) && lclc->nm != 99) {
        ierr=-200;
      }
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4rec_mode_enc(output,count,lclc)
char *output;
int *count;
struct k4rec_mode_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
  case 1:
    ivalue = lclc->bw;
    if (ivalue >=0 && ivalue <BW_KEY)
      strcpy(output,bw_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 2:
    ivalue = lclc->bt;
    if (ivalue >=0 && ivalue <BT_KEY)
      strcpy(output,bt_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 3:
    ivalue = lclc->ch;
    if (ivalue >=0 && ivalue <CH_KEY)
      strcpy(output,ch_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 4:
    ivalue = lclc->im;
    if (ivalue >=0 && ivalue <IM_KEY)
      strcpy(output,im_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 5:
    ivalue = lclc->nm;
    if ((ivalue >=0 && ivalue <=30||ivalue==99))
      sprintf(output,"%d",ivalue);
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
void k4rec_mode_mon(output,count,lclm,lclc)
char *output;
int *count;
struct k4rec_mode_mon *lclm;
struct k4rec_mode_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    ivalue = lclm->fm;
    if (ivalue >=0 && ivalue <FM_KEY)
      strcpy(output,fm_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 2:
    ivalue = lclm->ts;
    if (ivalue >=0 && ivalue <TS_KEY)
      strcpy(output,ts_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 3:
    ivalue = lclm->ta;
    if (ivalue >=0 && ivalue <=1)
      sprintf(output,"%d",ivalue);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 4:
    ivalue = lclm->pb;
    if (ivalue >=0 && ivalue <=100)
      sprintf(output,"%d",ivalue);
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
 ib_req7(ip,device,16,"FMT?");
 ib_req7(ip,device,16,"TSM?");
 ib_req7(ip,device,16,"DTS?");
}

k4rec_mode_req_c(ip,lclc)
long ip[5];
struct k4rec_mode_cmd *lclc;
{
  char buffer[MAX_BUF];

  strcpy(buffer,"SPM=");
  strcat(buffer,ch_key[lclc->ch]);
  strcat(buffer,",");
  strcat(buffer,bt_key[lclc->bt]);
  strcat(buffer,",");
  strcat(buffer,bw_key[lclc->bw]);
  ib_req2(ip,device,buffer);

  ib_req2(ip,device,"FMT=OLD");

  sprintf(buffer, "TSM=ON,%s,%2.2d",im_key[lclc->im],lclc->nm);
  ib_req2(ip,device,buffer);
  ib_req2(ip,device,"DTS=0,0");

}

k4rec_mode_res_q(lclc,lclm,ip)
struct k4rec_mode_cmd *lclc;
struct k4rec_mode_mon *lclm;
long ip[5];
{
  char buffer[MAX_BUF],*ptr;
  int max,i;

  lclc->bw=-1;
  lclc->bt=-1;
  lclc->ch=-1;
  lclm->fm=-1;
  lclm->ts=-1;
  lclc->im=-1;
  lclc->nm=-1;
  lclm->ta=-1;
  lclm->pb=-1;

/* SPM Message */

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  ptr=strtok(buffer,"=");
  if(ptr==NULL)
    return -1;

  if(strcmp(ptr,"SPM")!=0)
     return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;

  for(i=0;i<CH_KEY;i++)
    if(strcmp(ptr,ch_key[i])==0)
      lclc->ch=i;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  for(i=0;i<BT_KEY;i++)
    if(strcmp(ptr,bt_key[i])==0)
      lclc->bt=i;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  for(i=0;i<BW_KEY;i++)
    if(strcmp(ptr,bw_key[i])==0)
      lclc->bw=i;
   
/* FMT Message */

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  ptr=strtok(buffer,"=");
  if(ptr==NULL)
    return -1;
  if(strcmp(ptr,"FMT")!=0)
     return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  for(i=0;i<FM_KEY;i++)
    if(strcmp(ptr,fm_key[i])==0)
      lclm->fm=i;
  
/* TSM Message */

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

  ptr=strtok(buffer,"=");
  if(ptr==NULL)
    return -1;
  if(strcmp(ptr,"TSM")!=0)
     return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  for(i=0;i<TS_KEY;i++)
    if(strcmp(ptr,ts_key[i])==0)
      lclm->ts=i;
  
  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  for(i=0;i<IM_KEY;i++)
    if(strcmp(ptr,im_key[i])==0)
      lclc->im=i;
  
  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d",&lclc->nm))
    return -1;
  
  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;

/* DTS Message */

  ptr=strtok(buffer,"=");
  if(ptr==NULL)
    return -1;
  if(strcmp(ptr,"DTS")!=0)
     return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    return -1;
  if(1!=sscanf(ptr,"%d",&lclm->ta))
    return -1;

  ptr=strtok(NULL,",");
  if(ptr==NULL)
    lclm->pb=0;
  else if(1!=sscanf(ptr,"%d",&lclm->pb))
    return -1;

}




