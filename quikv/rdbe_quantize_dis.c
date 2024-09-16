/*
 * Copyright (c) 2024 NVI, Inc.
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
/* rdbe_quantize SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT MAX_CLS_MSG_BYTES
#define BUFSIZE MAX_CLS_MSG_BYTES

extern char unit_letters[];

void rdbe_quantize_dis(command,iwhich,ip,out_class,out_recs,kcom,kmon,kcombined,ifs,chans)
struct cmd_ds *command;
int iwhich;
int ip[5];
int *out_class;
int *out_recs;
int kcom;
int kmon;
int kcombined;
int ifs;
int chans;
{
  int ierr, count, i;
  char output[MAX_OUT];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE];
  int iclass, nrecs;
  struct rdbe_quantize_cmd lclc;
  struct rdbe_quantize_mon lclm;
  char who[3]="cn";
  int prefix;

  ierr = 0;

  if(iwhich !=0)
    sprintf(output,"%s(%c)",command->name,unit_letters[iwhich]);
  else
    strcpy(output,command->name);
  strcat(output,"/");
  prefix=strlen(output);

  if(kcom) {
    memcpy(&lclc,&shm_addr->rdbe_quantize[iwhich],sizeof(lclc));
  } else if (!kmon && shm_addr->equip.rack_type != RDBE) {
    ierr=logmsg_rdbe(output,command,ip,out_class,out_recs);
    if(ierr!=0) {
      ierr+=-450;
      goto error2;
    }
    return;
  } else {
    iclass=ip[0];
    nrecs=ip[1];
    if(nrecs> MAX_RDBE_IF) {
      ierr = -400;
      cls_clr(iclass);
      goto error2;
    }
    for (i=0;i<nrecs;i++) {
      if ((nchars =
            cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
        ierr = -401-i;
        if(i<nrecs-1)
          cls_clr(iclass);
        goto error2;
      }
      if(0!=rdbe_2_rdbe_quantize(inbuf,&lclm,ip,i)) {
        if(i<nrecs-1)
          cls_clr(iclass);
        goto error;
      }
      if (nrecs==1 && !kmon && shm_addr->equip.rack_type == RDBE && kcombined) {
        char *ptr, *if0ptr, *if1ptr, *from_ptr, *to_ptr;
        int j;
        int iend;
        ptr=strchr(inbuf,':');
        if(ptr==NULL) {
          if(i<nrecs-1)
            cls_clr(iclass);
          ierr=-410;
          goto error2;
        }
        if0ptr=ptr+1;
        if(chans==-1)
          iend=MAX_RDBE_CH+1;
        else
          iend=2;
        for(j=0;j<iend;j++) {
          ptr=strchr(ptr+1,':');
          if(ptr==NULL) {
            if(i<nrecs-1)
              cls_clr(iclass);
            ierr=-411;
            goto error2;
          }
        }
        if1ptr=ptr+1;
        for(from_ptr=if1ptr,to_ptr=if0ptr ;*from_ptr!=NULL; from_ptr++,to_ptr++)
          *to_ptr=*from_ptr;
        *to_ptr=*from_ptr;
        if(0!=rdbe_2_rdbe_quantize(inbuf,&lclm,ip,i+1)) {
          if(i<nrecs-1)
            cls_clr(iclass);
          goto error;
        }
      }
    }
  }

  if(kcom) {
    count=0;
    while( count>= 0) {
      if (count > 0) strcat(output,",");
      count++;
      rdbe_quantize_enc(output,&count,&lclc);
    }
    if(strlen(output)>0) output[strlen(output)-1]='\0';
    cls_snd(out_class,output,strlen(output),0,0);
    (*out_recs)++;
  } else {
    for (i=0;i<ifs;i++) {
      count=0;
      output[prefix]=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        rdbe_quantize_mon(output,&count,&lclm,iwhich,i,chans);
      }
      if(strlen(output)>0) output[strlen(output)-1]='\0';
      cls_snd(out_class,output,strlen(output),0,0);
      (*out_recs)++;
    }

  }
  for(i=0;i<5;i++)
    ip[i]=0;
  return;

error2:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"2e",2);
error:
  who[1]=unit_letters[iwhich];
  memcpy(ip+4,who,2);
  return;
}
