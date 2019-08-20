/* k4 recorder rec buffer parsing utilities */

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

#include "../include/k4rec_ds.h"

static char device[]={"r1"};           /* device menemonics */

static char *state_key[ ]={"off","on"};

#define STATE_KEY  sizeof(state_key)/sizeof( char *)

#define MAX_BUF 512

void k4rec_mon(output,count,lcl)
char *output;
int *count;
struct k4rec_mon *lcl;
{
  int ivalue;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
    strcpy(output,lcl->pos);
    break;
  case 2:
    ivalue = lcl->drum;
    if (ivalue >=0 && ivalue <STATE_KEY)
      strcpy(output,state_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 3:
    ivalue = lcl->synch;
    if (ivalue >=0 && ivalue <STATE_KEY)
      strcpy(output,state_key[ivalue]);
    else
      sprintf(output,"BAD_VALUE",ivalue);
    break;
  case 4:
    strcpy(output,lcl->lost);
    break;
  case 5:
    sprintf(output,"0x%x",lcl->stat1);
    break;
  case 6:
    sprintf(output,"0x%x",lcl->stat2);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}

k4rec_req_q(ip)
int ip[5];
{
  ib_req7(ip,device,20,"SQN?");
  ib_req7(ip,device,20,"DRM?");
  ib_req7(ip,device,20,"SYT?");
  ib_req7(ip,device,20,"SYN?");
  ib_req8(ip,device,10,"STAT?");
}

k4rec_req_eject(ip)
int ip[5];
{
  ib_req2(ip,device,"UNL");
}

k4rec_req_ini(ip)
int ip[5];
{
  ib_req2(ip,device,"INI");
}

k4rec_req_xsy(ip)
int ip[5];
{
  ib_req2(ip,device,"XSY");
}

k4rec_req_drum_on(ip)
int ip[5];
{
  ib_req2(ip,device,"DRM=ON");
}

k4rec_req_drum_off(ip)
int ip[5];
{
  ib_req2(ip,device,"DRM=OFF");
}

k4rec_req_synch_on(ip)
int ip[5];
{
  ib_req2(ip,device,"SYT=ON");
}

k4rec_req_synch_off(ip)
int ip[5];
{
  ib_req2(ip,device,"SYT=OFF");
}

k4rec_req_prl(ip,ptr)
int ip[5];
char *ptr;
{
  char buff[12];

  strcpy(buff,"PRL=");
  if(strlen(ptr) < 8)
    strcat(buff,ptr);
  else {
    strncpy(buff+4,ptr,7);
    buff[12]=0;
  }

  ib_req2(ip,device,buff);
}

k4rec_res_q(lcl,ip)
struct k4rec_mon *lcl;
int ip[5];
{
  unsigned char buffer[MAX_BUF];
  int max;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  if(1!=sscanf(buffer,"SQN=%8s",lcl->pos))
    if(strcmp(buffer,"NULL")==0)
      strcpy(lcl->pos,"NULL");

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  if(strcmp(buffer,"DRM=ON")==0)
    lcl->drum=1;
  else if(strcmp(buffer,"DRM=OFF")==0)
    lcl->drum=0;
  else
    lcl->drum=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  if(strcmp(buffer,"SYT=ON")==0)
    lcl->synch=1;
  else if(strcmp(buffer,"SYT=OFF")==0)
    lcl->synch=0;
  else
    lcl->synch=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0)
    return -1;
  sscanf(buffer,"SYN=%2s",lcl->lost);

  max=sizeof(buffer);
  ib_res_bin(buffer,&max,ip);
  if(max < 0)
    return -1;
  lcl->stat1=buffer[0];
  lcl->stat2=buffer[1];
   
}

