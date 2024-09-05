/*
 * Copyright (c) 2020, 2024 NVI, Inc.
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
/* RDBE connect SNAP command */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512
extern char unit_letters[];

void rdbe_connect(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
  int ilast, ierr, ind, i, count, j;
  char *ptr;
  char *arg_next();
  int out_recs[MAX_RDBE], out_class[MAX_RDBE];
  char outbuf[BUFSIZE];
  struct rdbe_connect_cmd lclc;
  int increment;
  int iplast[5];
  int iwhich;
  int rtn_class=0;
  int rtn_recs=0;
  int some=FALSE;
  char *prdbe,*str,rdbe;
  int irdbe, kmon=0, kcom=0;

  void skd_run(), skd_par();      /* program scheduling utilities */

  irdbe=0;   /* assume this is an all device command to begin with */

  if (command->equal != '=') {
    for (i=0;i<MAX_RDBE;i++) {
      out_recs[i]=0;
      out_class[i]=0;
      if(shm_addr->rdbe_active[i])
        some=TRUE;
    }
    if(!some) {
      ierr=-301;
      goto error;
    }

    str="dbe_data_connect?;\n";
    for (i=0;i<MAX_RDBE;i++)
      if(shm_addr->rdbe_active[i]) {
        cls_snd(&out_class[i], str, strlen(str) , 0, 0);
        out_recs[i]++;
      }
    kmon=1;
    goto rdbcn;
  } else if (command->argv[0]==NULL) { /* simple equals */
    goto parse;
  } else if (command->argv[1]==NULL) /* special cases */
    if (*command->argv[0]=='?') {
      kcom=1;
      rdbe_connect_dis(command,irdbe,ip,&rtn_class,&rtn_recs,kcom,kmon);
      ip[0]=rtn_class;
      ip[1]=rtn_recs;
      return;
    }

  /* is the first parameter the RDBE to address? */

  rdbe=' ';
  ierr=arg_char(command->argv[0],&rdbe,' ',FALSE);
  if(ierr ==-100) {
    ierr=0;
    goto parse;
  }
  prdbe=strchr(unit_letters+1,rdbe);
  if(ierr==-200||prdbe==NULL|| prdbe-unit_letters>MAX_RDBE ) {
    ierr=0;
    goto parse;
  }

/* if we get this far it is for one device */

  irdbe=prdbe-unit_letters;
  if (command->argv[1]!=NULL && *command->argv[1]=='?'
      && command->argv[2] == NULL) {
    kcom=1;
    rdbe_connect_dis(command,irdbe,ip,&rtn_class,&rtn_recs,kcom,kmon);
    ip[0]=rtn_class;
    ip[1]=rtn_recs;
    return;
  } else if (command->argv[1]==NULL) {
    for (i=0;i<MAX_RDBE;i++) {
      out_recs[i]=0;
      out_class[i]=0;
    }
    str="dbe_data_connect?;\n";
    cls_snd(&out_class[irdbe-1], str, strlen(str) , 0, 0);
    out_recs[irdbe-1]++;
    kmon=1;
    goto rdbcn;
  }

parse:
  ilast=0;                                      /* last argv examined */
  if(irdbe!=0)
    ilast++;

  memcpy(&lclc,&shm_addr->rdbe_connect[irdbe],sizeof(lclc));

  count=1;
  while( count>= 0) {
    ptr=arg_next(command,&ilast);
    ierr=rdbe_connect_dec(&lclc,&count, ptr);
    if(ierr !=0 ) goto error;
  }

  for (i=0;i<MAX_RDBE;i++) {
    out_recs[i]=0;
    out_class[i]=0;
    if(shm_addr->rdbe_active[i]!=0 && irdbe ==0)
      some=TRUE;
  }

  if(irdbe==0) {
    if(!some) {
      ierr=-301;
      goto error;
    }
    memcpy(&shm_addr->rdbe_connect[irdbe],&lclc,sizeof(lclc));
  }

  for (i=0;i<MAX_RDBE;i++)
    if(irdbe == i+1 || shm_addr->rdbe_active[i]!=0 && irdbe ==0 ) {
      memcpy(&shm_addr->rdbe_connect[i+1],&lclc,sizeof(lclc));
    }

  rdbe_connect_2_rdbe(outbuf,&lclc);
  if(outbuf[0]!=0)
    for (i=0;i<MAX_RDBE;i++)
      if(irdbe == i+1 || shm_addr->rdbe_active[i]!=0 && irdbe ==0 ) {
        cls_snd(&out_class[i], outbuf, strlen(outbuf) , 0, 0);
        out_recs[i]++;
      }

rdbcn:
  for (i=0;i<MAX_RDBE;i++)
    if(out_recs[i]) {
      char name[6];
      ip[0]=1;
      ip[1]=out_class[i];
      ip[2]=out_recs[i];
      sprintf(name,"rdbc%c",unit_letters[i+1]);
      iwhich=i+1;
      skd_run_p(name,'p',ip,&iwhich); /* from here until the last
                                         skd_run_p(NULL,'w',...) is
                                         processed, we have to handle
                                         errors locally, no passing up
                                         i.e. too hard to unwind */
    }
  for(j=0;j<5;j++)
    iplast[j]=0;

  for (i=0;i<MAX_RDBE;i++)
    if(irdbe == i+1 || shm_addr->rdbe_active[i]!=0 && irdbe == 0) {
      skd_run_p(NULL,'w',ip,&iwhich);
      skd_par(ip);
      if(ip[2]<0) {
        if(ip[0]!=0) {
          cls_clr(ip[0]);
          ip[0]=ip[1]=0;
        }
      } else
        rdbe_connect_dis(command,iwhich,ip,&rtn_class,&rtn_recs,kcom,kmon);
      if(irdbe !=0)
        continue;

      if(ip[2]!=0 && iplast[2]!=0) {
        logita(NULL,iplast[2],iplast+3,iplast+4);
      }
      if(ip[2]!=0)
        for(j=2;j<5;j++)
          iplast[j]=ip[j];
    }

  /* local error processing no longer require */
  if(iplast[2]!=0)
    for(j=2;j<5;j++)
      ip[j]=iplast[j];

  ip[0]=rtn_class;
  ip[1]=rtn_recs;

  return;

error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"2j",2);
  return;
}
