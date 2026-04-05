/*
 * Copyright (c) 2026 NVI, Inc.
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
/* dbbc3 ext_lo snap command */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc3_ext_lo(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, count, i;
      char *ptr;
      struct dbbc3_ext_lo_table lcl;     /* local instance of table struct */
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      int dbbc3_ext_lo_dec();               /* parsing utilities */
      char *arg_next();

      void dbbc3_ext_lo_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */
      static char *synth[]={" ","1","2","3","4"};

      static char *lo3_key[ ]={"loa","lob","loc","lod","loe","lof","log","loh"};
#define NLO3_KEY sizeof(lo3_key)/sizeof( char *)

      int ilo;
      int kcheck=0;
      int kmon=1;

      if (command->equal != '=' || NULL!=command->argv[0] && *command->argv[0] == '?') {

          if(command->equal == '=' && NULL!=command->argv[1]) {
              ierr=-301;
              goto error;
          }
          if(!shm_addr->dbbc3_ext_lo.count) {
              ip[0]=ip[1]=ip[2]=ip[3]=ip[4]=0;
              return;
          }
          int options=1;
          for (i=0;i<shm_addr->dbbc3_ext_lo.count;i++) {
              if(i==shm_addr->dbbc3_ext_lo.count-1)
                  options=0;

              dbbc3_ext_lo_dis(command,itask,ip,i,options);
              if(ip[2]!=0)
                  return;
          }
          return;
      } else if(NULL==command->argv[0]) {
          shm_addr->dbbc3_ext_lo.count=0;
          ip[0]=ip[1]=ip[2]=ip[3]=ip[4]=0;
          return;
      }

      if(0==strcmp(command->argv[0],"all")) {
          if(NULL==command->argv[1]) {
              double freq;
              int sb;
              int options=1;
              for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                  int itable=find_ext_lo(i, &freq, &sb);
                  if(itable<-1) {
                      ierr=-303;
                      ip[4]=ilo;
                      goto error;
                  }
                  if(i==shm_addr->dbbc3_ddc_ifs-1)
                      options=0;
                  dbbc3_ext_lo_dis(command,itask,ip,itable,options);
              }
              return;
          } else
              ilo=-1;
      } else {
          if(0==strcmp(command->argv[0],"*")) {
             ierr=-111;
             goto error;
          }
          ierr=arg_key(command->argv[0],lo3_key,NLO3_KEY,&ilo,-1,TRUE);
          if(ierr!=0) {
              ierr+=-1;
              goto error;
          } else if(ilo+1>shm_addr->dbbc3_ddc_ifs) {
              ierr=-201;
              goto error;
          } else if(NULL == command->argv[1]) {
              double freq;
              int sb;
              int itable=find_ext_lo(ilo, &freq, &sb);
              if(itable<-1) {
                  ierr=-303;
                  ip[4]=ilo;
                  goto error;
              }
              dbbc3_ext_lo_dis(command,itask,ip,itable,0);
              return;
          } else if(NULL != command->argv[1] && *command->argv[1] == '?') {
              if(NULL != command->argv[2]) {
                  ierr=-301;
                  goto error;
              }
              int thislo=0;
              for (i=0;i<shm_addr->dbbc3_ext_lo.count;i++)
                  if(shm_addr->dbbc3_ext_lo.table[i].ifc==-1 || shm_addr->dbbc3_ext_lo.table[i].ifc==ilo)
                      thislo++;
              if(!thislo) {
                  dbbc3_ext_lo_dis(command,itask,ip,-1,0);
                  return;
              }
              int options=1;
              for (i=0;i<shm_addr->dbbc3_ext_lo.count;i++)
                  if(shm_addr->dbbc3_ext_lo.table[i].ifc==-1 || shm_addr->dbbc3_ext_lo.table[i].ifc==ilo) {
                      if(i==thislo-1)
                          options=0;
                      dbbc3_ext_lo_dis(command,itask,ip,i,options);
                  }
              return;
          }
      }

/* if we arrive here, it is a set-up command so parse it */

parse:
      if(shm_addr->dbbc3_ext_lo.count>=MAX_DBBC3_EXT_LO_TABLE) {
          ierr=-302;
          goto error;
      }

      ilast=1;                                      /* last argv examined */

      count=2;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbc3_ext_lo_dec(&lcl,&count,ptr,itask);
        if(ierr !=0 ) goto error;
      }

      lcl.ifc=ilo;
      memcpy(shm_addr->dbbc3_ext_lo.table+shm_addr->dbbc3_ext_lo.count++,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=ip[3]=ip[4]=0;
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"do",2);
      return;
}
