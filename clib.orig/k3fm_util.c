/* k3 formatter parsing utilities */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"f3"};           /* device menemonics */

static char *key_mode[ ]={"a","b","c","d"};
static char *key_rate[ ]={ "0.25", "0.5", "1", "2", "4", "8"};
static char *key_inpt[ ]={ "nor", "ext", "crc", "low", "high"};
static char *key_sync[ ]={ "on", "off"};
static char *key_auxs[ ]={ "frm", "1pps"};
static char *key_outp[ ]={ "nor", "low", "high"};

#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_RATE sizeof(key_rate)/sizeof( char *)
#define NKEY_INPT sizeof(key_inpt)/sizeof( char *)
#define NKEY_SYNC sizeof(key_sync)/sizeof( char *)
#define NKEY_AUXS sizeof(key_auxs)/sizeof( char *)
#define NKEY_OUTP sizeof(key_outp)/sizeof( char *)

#define MAX_BUF 512

int k3fm_dec(lcl,new_aux,count,ptr)
struct k3fm_cmd *lcl;
int *new_aux,*count;
char *ptr;
{
    int ierr, arg_int();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,key_mode,NKEY_MODE,&lcl->mode,0,FALSE);
      break;
    case 2:
      ierr=arg_key_flt(ptr,key_rate,NKEY_RATE,&lcl->rate,4,TRUE);
      break;
    case 3:
      ierr=arg_key(ptr,key_inpt,NKEY_INPT,&lcl->input,0,TRUE);
      break;
    case 4:
      if(strlen(ptr) > 12) {
	ierr=-200;
	goto end;
      } else if(strlen(ptr)==0)
	*new_aux=0;
      else {
	int i;

	for(i=0;i<strlen(ptr);i++)
	  if(!isxdigit(ptr[i])) {
	    ierr=-200;
	    goto end;
	  }
	strncpy(lcl->aux,ptr,strlen(ptr));
	for(i=0;i<12;i++)
	  lcl->aux[i]=toupper(lcl->aux[i]);
	*new_aux=1;
      }
      break;
    case 5:
      ierr=arg_key(ptr,key_sync,NKEY_SYNC,&lcl->synch,0,TRUE);
      break;
    case 6:
      ierr=arg_key(ptr,key_auxs,NKEY_AUXS,&lcl->aux_start,0,TRUE);
      break;
    case 7:
      ierr=arg_key(ptr,key_outp,NKEY_OUTP,&lcl->output,0,TRUE);
      break;
    default:
      *count=-1;
    }

end:
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k3fm_enc(output,count,lcl)
char *output;
int *count;
struct k3fm_cmd *lcl;
{
  int ivalue, type;

  output=output+strlen(output);

  switch (*count) {
  case 1:
    ivalue = lcl->mode;
    if (ivalue >=0 && ivalue <NKEY_MODE)
      strcpy(output,key_mode[ivalue]);
    else
      strcpy(output,BAD_VALUE);
    break;
  case 2:
    ivalue=lcl->rate;
    if(ivalue>=0 && ivalue <NKEY_RATE)
      strcpy(output,key_rate[ivalue]);
    else
      strcpy(output,BAD_VALUE);
    break;
  case 3:
    ivalue=lcl->input;
    if(ivalue>=0 && ivalue <NKEY_INPT)
      strcpy(output,key_inpt[ivalue]);
    else
      strcpy(output,BAD_VALUE);
    break;
  case 4:
    strncpy(output,lcl->aux,12);
    output[12]=0;
    break;
  case 5:
    ivalue=lcl->synch;
    if(ivalue>=0 && ivalue <NKEY_SYNC)
      strcpy(output,key_sync[ivalue]);
    else
      strcpy(output,BAD_VALUE);
    break;
  case 6:
    ivalue=lcl->aux_start;
    if(ivalue>=0 && ivalue <NKEY_AUXS)
      strcpy(output,key_auxs[ivalue]);
    else
      strcpy(output,BAD_VALUE);
    break;
  case 7:
    ivalue=lcl->output;
    if(ivalue>=0 && ivalue <NKEY_OUTP)
      strcpy(output,key_outp[ivalue]);
    else
      strcpy(output,BAD_VALUE);
    break;
  default:
    *count=-1;
  }

}

void k3fm_mon(output,count,lcl)
char *output;
int *count;
struct k3fm_mon *lcl;
{
  int ivalue, type;

  output=output+strlen(output);

  switch (*count) {
  case 1:
    strncpy(output,lcl->daytime,15);
    output[15]=0;
    break;
  case 2:
  case 3:
  case 4:
    sprintf(output,"0x%02x",lcl->status[*count-2]);
    break;
  default:
    *count=-1;
  }

}

k3fm_req_q(ip)
long ip[5];
{
 ib_req7(ip,device,20,"INP?");
 ib_req7(ip,device,20,"MOD?");
 ib_req7(ip,device,20,"OUT?");
 ib_req7(ip,device,20,"SMP?");
 ib_req7(ip,device,20,"AUX?");
 ib_req7(ip,device,20,"SYT?");
 ib_req7(ip,device,20,"AUT?");
 ib_req7(ip,device,20,"DATA=TIME");
 ib_req8(ip,device,20,"STAT=*");

}
k3fm_req_c(ip,lclc,new_aux)
long ip[5];
struct k3fm_cmd *lclc;
int new_aux;
{
  char buffer[20];

  switch (lclc->input) {
  default:
  case 0:
    strcpy(buffer,"INP=NOR");
    break;
  case 1:
    strcpy(buffer,"INP=EXT");
    break;
  case 2:
    strcpy(buffer,"INP=TST");
    break;
  case 3:
    strcpy(buffer,"INP=LOW");
    break;
  case 4:
    strcpy(buffer,"INP=HI");
    break;
  }
  ib_req2(ip,device,buffer);

  switch (lclc->mode) {
  case 0:
    strcpy(buffer,"MOD=A");
    break;
  case 1:
    strcpy(buffer,"MOD=B");
    break;
  default:
  case 2:
    strcpy(buffer,"MOD=C");
    break;
  case 3:
    strcpy(buffer,"MOD=D");
    break;
  }
  ib_req2(ip,device,buffer);

  switch (lclc->output) {
  default:
  case 0:
    strcpy(buffer,"OUT=NOR");
    break;
  case 1:
    strcpy(buffer,"OUT=LOW");
    break;
  case 2:
    strcpy(buffer,"OUT=HI");
    break;
  }
  ib_req2(ip,device,buffer);

  switch (lclc->rate) {
  case 0:
    strcpy(buffer,"SMP=025");
    break;
  case 1:
    strcpy(buffer,"SMP=050");
    break;
  case 2:
    strcpy(buffer,"SMP=100");
    break;
  case 3:
    strcpy(buffer,"SMP=200");
    break;
  default:
  case 4:
    strcpy(buffer,"SMP=400");
    break;
  case 5:
    strcpy(buffer,"SMP=800");
    break;
  }
  ib_req2(ip,device,buffer);

  switch (lclc->synch) {
  default:
  case 0:
    strcpy(buffer,"SYT=ON");
    break;
  case 1:
    strcpy(buffer,"SYT=OFF");
    break;
  }
  ib_req2(ip,device,buffer);

  switch (lclc->aux_start) {
  default:
  case 0:
    strcpy(buffer,"AUT=FRM");
    break;
  case 1:
    strcpy(buffer,"AUT=1PS");
    break;
  }
  ib_req2(ip,device,buffer);

  if(new_aux) {
    strcpy(buffer,"AUX=");
    strncat(buffer,lclc->aux,12);
    buffer[16]=0;
    ib_req2(ip,device,buffer);
  }
}

k3fm_res_q(lclc,lclm,ip)
struct k3fm_cmd *lclc;
struct k3fm_mon *lclm;
long ip[5];
{
  char buffer[MAX_BUF];
  int max,i;
  int icount;
  char lohi, loup;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }

  if(strcmp(buffer+2,"INP=NOR")==0)
    lclc->input=0;
  else if(strcmp(buffer+2,"INP=EXT")==0)
    lclc->input=1;
  else if(strcmp(buffer+2,"INP=TST")==0)
    lclc->input=2;
  else if(strcmp(buffer+2,"INP=LOW")==0)
    lclc->input=3;
  else if(strcmp(buffer+2,"INP=HI")==0)
    lclc->input=4;
  else
    lclc->input=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  if(strcmp(buffer+2,"MOD=A")==0)
    lclc->mode=0;
  else if(strcmp(buffer+2,"MOD=B")==0)
    lclc->mode=1;
  else if(strcmp(buffer+2,"MOD=C")==0)
    lclc->mode=2;
  else if(strcmp(buffer+2,"MOD=D")==0)
    lclc->mode=3;
  else
    lclc->mode=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  if(strcmp(buffer+2,"OUT=NOR")==0)
    lclc->output=0;
  else if(strcmp(buffer+2,"OUT=LOW")==0)
    lclc->output=1;
  else if(strcmp(buffer+2,"OUT=HI")==0)
    lclc->output=2;
  else
    lclc->output=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  if(strcmp(buffer+2,"SMP=025")==0)
    lclc->rate=0;
  else if(strcmp(buffer+2,"SMP=050")==0)
    lclc->rate=1;
  else if(strcmp(buffer+2,"SMP=100")==0)
    lclc->rate=2;
  else if(strcmp(buffer+2,"SMP=200")==0)
    lclc->rate=3;
  else if(strcmp(buffer+2,"SMP=400")==0)
    lclc->rate=4;
  else if(strcmp(buffer+2,"SMP=800")==0)
    lclc->rate=5;
  else
    lclc->rate=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  strncpy(lclc->aux,buffer+6,12);

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  if(strcmp(buffer+2,"SYT=ON")==0)
    lclc->synch=0;
  else if(strcmp(buffer+2,"SYT=OFF")==0)
    lclc->synch=1;
  else
    lclc->synch=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  if(strcmp(buffer+2,"AUT=FRM")==0)
    lclc->aux_start=0;
  else if(strcmp(buffer+2,"AUT=1PS")==0)
    lclc->aux_start=1;
  else
    lclc->aux_start=-1;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  strncpy(lclm->daytime,buffer+2,15);

  max=sizeof(buffer);
  ib_res_bin(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }
  lclm->status[0]=buffer[2];
  lclm->status[1]=buffer[3];
  lclm->status[2]=buffer[4];

}


