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
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <string.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "../rclco/rcl/rcl.h"

#include "fserr.h"

/*                                                                 */
/*  FSERR is the routine which sends DDOUT the appropriate error   */
/*  message for the given two character mnemonic and error number. */
/*  The error information is read into a large structure array     */
/*  from first the station error control file sterr.ctl and then   */
/*  the Field System error control file fserr.ctl. A Hash routine  */
/*  is used to set and find the position for each message in the   */
/*  array.                                                         */

/*                                                                 */
/*  HISTORY:                                                       */
/*  WHO  WHEN    WHAT                                              */
/*  gag  920917  Rewrote to use a structured array instead of the  */
/*               index files.                                      */
/*                                                                 */

extern struct fscom *shm_addr;

struct errorlist{       /* structure type to store error information */
  char mnemonic[2];
  int ierr;
  char message[120];
};

struct errorlist list[MAXERRORS];

struct error_struct {
  int value;
  char *mnem;
  struct error_struct *next;
};

struct error_struct *error_base=NULL;

FILE *dcbfs;

main(){
  int fserr_rcv();
  int class, ip[5];
  int rtn1, rtn2;
  char inbuf[120];
  int i;
  int len;
  int hash;
  int hashcount;
  char device[2];

  struct {
    char buf[2];
    int off;
  } entry;

  setup_ids();

/*  zero out the error number position in the error structure */
  for (i=0; i < MAXERRORS; i++)
    list[i].ierr=0;

/* Read in the error messages from station control file, sterr, first */
/* initializing the array with the error information using subroutine */
/* listinit.                                                          */

  if ((dcbfs=fopen(CTLST, "r"))==NULL) {
    fprintf(stderr,"fserr: error opening %s\n",CTLST);
    perror("fserr");
  } else {
    listinit(dcbfs,&list,CTLST);
    fclose(dcbfs);
  }

/* Read in the error messages from FS control file, fserr */

  if ((dcbfs=fopen(CTLFS, "r"))==NULL) {
    fprintf(stderr,"fserr: error opening %s\n",CTLFS);
    perror("fserr");
  } else {
    listinit(dcbfs,&list,CTLFS);
    fclose(dcbfs);
  }

  skd_wait("fserr", ip, 0);
  if(ip[0]==-1) exit(-1);

/* call to retrieve parameter string */
  fserr_rcv(inbuf, 80);
  inbuf[80]='\0';   /* make sure it is null terminated */

/* main rept-until loop done once for each err reported */

Repeat: 
  
  inbuf[48]=' ';
  if(memcmp(inbuf, "##", 2)==0){ 
    printf("number of entries = ");
    goto Suspend; 
  } 

  while(inbuf[0]!= ' ')     /* find the first space to delimit error code */
    for(i=0;i<79;++i)
      inbuf[i]=inbuf[i+1];

  if(inbuf[0]== ' ')       /* skip the space */
    for(i=0;i<79;++i)
      inbuf[i]=inbuf[i+1];

  for(i=0;i<80;++i) {      /* use upper case for search */
      inbuf[i]=toupper(inbuf[i]);
  }

  entry.buf[0]=0;
  entry.off=0;
  device[0]=0;
  device[1]=0;
  i = sscanf(inbuf,"%2s %d (%2c)",entry.buf,&entry.off, device);
  if(i==3 && strncmp(entry.buf,"RL",2)==0 && entry.off > -129 
     && entry.off < 0 ) {
    struct rclcn_req_buf req_buf;
    struct rclcn_res_buf res_buf;
    char err_msg[RCL_MAXSTRLEN_ERROR_DECODE];
    int ierr;
    int ip[5];
    char *first;
    struct error_struct *ptr,*new,*last=NULL,**clean_up;

    for (ptr=error_base;ptr!=NULL;ptr=ptr->next) {
      last=ptr;
      if(ptr->value==entry.off) {
	strcpy(inbuf,ptr->mnem);
	len=strlen(inbuf);
	goto done;
      }
    }

    ini_rclcn_req(&req_buf);
    device[0]=tolower(device[0]);
    device[1]=tolower(device[1]);
    add_rclcn_error_decode(&req_buf,device,entry.off);
    end_rclcn_req(ip,&req_buf);
    skd_run("rclcn",'w',ip);
    skd_par(ip);
    if(ip[2]!=0) {
      cls_clr(ip[0]);
      ip[0]=0;
      ip[1]=1;
      if(ip[2]> -129 && ip[2] < 0 && strncmp((char *)ip+3,"rl",2)==0)
	ip[2]-=1000;
      logita(NULL,ip[2],ip+3,ip+4);
      goto none;
    }

    opn_rclcn_res(&res_buf,ip);
    ierr=get_rclcn_error_decode(&res_buf,err_msg);
    first=strchr(err_msg,':');
    if(first == NULL) {
      logit(NULL,-902,"er");
      goto none;
    }
    first+=2;
    len = strlen(first)+1;
    if(len > 81)
      len=81;
    memcpy(inbuf,first,len);
    if(len==81) inbuf[80]=0;

    new=NULL;
    if(error_base==NULL) {
      new=malloc( sizeof(struct error_struct));
      error_base=new;
      clean_up=&error_base;
    } else {
      new=malloc(sizeof(struct error_struct));
      last->next=new;
      clean_up=&last->next;
    }

    if(new!=NULL) {
      new->next=NULL;
      new->value=entry.off;
      new->mnem=malloc(strlen(inbuf)+1);
      if(new->mnem==NULL) {
	free(new);
	*clean_up=NULL;
      } else
	strcpy(new->mnem,inbuf);
    }
    goto done;
  }


  hashcode(&entry,&hash);
  hashcount=1;
  while ((memcmp(entry.buf,list[hash].mnemonic,2)!=0) || 
          (entry.off!=list[hash].ierr)) {
    hash+=1;
    if (hash==MAXERRORS)
      hash=0;
    hashcount+=1;
    if (hashcount >= MAXERRORS) 
      break;
  }

  if (hashcount==MAXERRORS)
    goto none;
  else
    goto found;

none:
    memcpy(inbuf,"nono",4);
    inbuf[4]='\0';
    len=4;
    goto done;

found:
    len = strlen(list[hash].message);
    memcpy(inbuf,list[hash].message,len);
    len-=1;

done:
  class = 0;
  fserr_snd(inbuf,len);

Suspend:

  ip[0] = class;
  skd_wait("fserr", ip, 0);
  if(ip[0]!=-1) {
    fserr_rcv(inbuf, 80);
    goto Repeat; 
  }


}
