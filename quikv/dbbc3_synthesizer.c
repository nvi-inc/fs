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
/* dbbc3 synthesizer snap command */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

static void add_check_queries( out_recs, out_class, ilo)
    int *out_recs;
    int *out_class;
    int ilo;
{
    char outbuf[BUFSIZE];

    sprintf(outbuf,"synth=%d,s%d;cw?;oen?;lk%d?;att?;mod?;refs?;ref?;off?;refdb?;refdiv?",1+ilo/2,1+ilo%2,1+ilo%2);
    cls_snd(out_class, outbuf, strlen(outbuf) , 0, 0);
    ++*out_recs;

    return;
}
void dbbc3_synthesizer(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, count, i;
      char *ptr;
      struct dbbc3_synthesizer_cmd lcl;     /* local instance of dbbcnn command struct */
      int out_recs, out_class;
      char outbuf[BUFSIZE];

      int dbbc3_synthesizer_dec();               /* parsing utilities */
      char *arg_next();

      void dbbc3_synthesizer_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */
      static char *synth[]={" ","1","2","3","4"};

      static char *lo3_key[ ]={"loa","lob","loc","lod","loe","lof","log","loh"};
#define NLO3_KEY sizeof(lo3_key)/sizeof( char *)

      int ilo;
      int kcheck=0;
      int kmon=1;

      if (command->equal != '=') {
          int options;

          for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
              shm_addr->dbbc3_synthesizer_previous_lo=i;
              out_class=0;
              out_recs=0;
              add_check_queries(&out_recs, &out_class, i);
              ip[0]=9;
              ip[1]=out_class;
              ip[2]=out_recs;
              skd_run("dbbcn",'w',ip);
              skd_par(ip);

              if(ip[2]<0) {
                  if(ip[0]!=0) {
                      cls_clr(ip[0]);
                      ip[0]=ip[1]=0;
                  }
                  return;
              }
              options=1;
              if(i==shm_addr->dbbc3_ddc_ifs-1)
                  options=0;

              dbbc3_synthesizer_dis(command,itask,ip,i,options,kmon,kcheck);
              if(ip[2]!=0)
                  return;
          }
          return;
      } else if(NULL==command->argv[0]) {
          for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
              shm_addr->dbbc3_synthesizer[i].setup=0;

              shm_addr->dbbc3_synthesizer[i].freq.freq=-1;
              m5state_init(&shm_addr->dbbc3_synthesizer[i].freq.state);

              shm_addr->dbbc3_synthesizer[i].output.output=-1;
              m5state_init(&shm_addr->dbbc3_synthesizer[i].output.state);

              shm_addr->dbbc3_synthesizer[i].ext_lo_freq.ext_lo_freq=-1;
              m5state_init(&shm_addr->dbbc3_synthesizer[i].ext_lo_freq.state);

              shm_addr->dbbc3_synthesizer[i].ext_lo_sb.ext_lo_sb=-1;
              m5state_init(&shm_addr->dbbc3_synthesizer[i].ext_lo_sb.state);

              shm_addr->dbbc3_synthesizer[i].input_sb.input_sb=-1;
              m5state_init(&shm_addr->dbbc3_synthesizer[i].input_sb.state);
          }
          ip[0]=ip[1]=ip[2]=ip[3]=ip[4]=0;
          return;
      } else if(*command->argv[0] == '?') {

          if(NULL!=command->argv[1]) {
              ierr=-301;
              goto error;
          }

          for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {

              int options=1;
              if(i==shm_addr->dbbc3_ddc_ifs-1)
                  options=0;

              dbbc3_synthesizer_dis(command,itask,ip,i,options,kmon,kcheck);
          }
          return;
      }

      if(0==strcmp(command->argv[0],"next")) {
          if(NULL == command->argv[1]) { /*  monitor */
              ilo=(1+shm_addr->dbbc3_synthesizer_previous_lo)%shm_addr->dbbc3_ddc_ifs;
          } else if(*command->argv[1] == '?') {
              ierr=-302;
              goto error;
          } else if(NULL != command->argv[2] && NULL != command->argv[3] &&
                  (0==strcmp(command->argv[3],"force")||0==strcmp(command->argv[3],"force_plus"))) {
              ierr=-303;
              goto error;
          } else if(NULL == command->argv[2] || NULL != command->argv[2] && NULL == command->argv[3]) {
              ierr=-306;
              goto error;
          } else if(NULL != command->argv[2] && NULL != command->argv[3] && 0!=strcmp(command->argv[3],"check")) {
              ierr=-204;
              goto error;
          } else { /* must be checking */
              if(0!=strcmp(command->argv[1],"*") || NULL == command->argv[2] || 0!=strcmp(command->argv[2],"*")) {
                ierr=-305;
                goto error;
              }
              ilo=shm_addr->dbbc3_synthesizer_previous_lo;
              for(i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                  ilo=(1+ilo)%shm_addr->dbbc3_ddc_ifs;
                  if(0!=shm_addr->dbbc3_synthesizer[ilo].setup)
                      break;
              }
              if(i==shm_addr->dbbc3_ddc_ifs) {
                  ierr=-304;
                  goto error;
              }
          }
      } else {
          if(0==strcmp(command->argv[0],"*")) {
              ierr=-111;
              goto error;
          }
          ierr=arg_key(command->argv[0],lo3_key,NLO3_KEY,&ilo,0,FALSE);
          if(ierr!=0) {
              ierr+=-1;
              goto error;
          } else if(ilo+1>shm_addr->dbbc3_ddc_ifs) {
              ierr=-201;
              goto error;
          } else if(NULL != command->argv[1] && *command->argv[1] == '?') {
              if(NULL != command->argv[2]) {
                  ierr=-301;
                  goto error;
              }
              dbbc3_synthesizer_dis(command,itask,ip,ilo,0,kmon,kcheck);
              return;
          }
          if(shm_addr->lo.lo[ilo] < 0.0 && NULL != command->argv[1]) { /* lo is not defined */
              if(0==strlen(command->argv[1]) && NULL != command->argv[2] && 0==strlen(command->argv[2])) {
                  if(NULL == command->argv[3]) {
                      ierr=-307;
                      goto error;
                  } else if( 0==strcmp(command->argv[3],"force") || 0==strcmp(command->argv[3],"force_plus") ||
                          0==strcmp(command->argv[3],"check")) { /* all defaults is a no-op for force/force_plus/check */
                      ip[0]=ip[1]=ip[2]=ip[3]=ip[4]=0;
                      return;
                  }
              }
          }
          if(!shm_addr->dbbc3_synthesizer[ilo].setup) { /* device is not setup */
              if(NULL != command->argv[1] && 0==strcmp(command->argv[1],"*") &&
                      NULL != command->argv[2] && 0==strcmp(command->argv[2],"*") &&
                      NULL != command->argv[3] &&
                      (0==strcmp(command->argv[3],"force") || 0==strcmp(command->argv[3],"check") ||
                       0==strcmp(command->argv[3],"force_plus")) ) {
                  ip[0]=ip[1]=ip[2]=ip[3]=ip[4]=0; /* all previous values is a no-op for check/force/force_plus */
                  return;
              }
          }
      }
      if(NULL == command->argv[1]) {
          out_recs=0;
          out_class=0;
          add_check_queries(&out_recs, &out_class, ilo);
          shm_addr->dbbc3_synthesizer_previous_lo=ilo;
          goto dbbcn;
      }

/* if we arrive here, it is a set-up command so parse it */

parse:

      ilast=1;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->dbbc3_synthesizer[ilo],sizeof(lcl));

      count=2;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbc3_synthesizer_dec(&lcl,&count, ptr,itask,ilo);
        if(ierr !=0 ) goto error;
      }

      lcl.setup=1;
      memcpy(&shm_addr->dbbc3_synthesizer[ilo],&lcl,sizeof(lcl));

/* format buffer for dbbcn */

      out_recs=0;
      out_class=0;

      if(1==lcl.check.check) {
          add_check_queries(&out_recs, &out_class, ilo);
          kcheck=1;
          shm_addr->dbbc3_synthesizer_previous_lo=ilo;
          goto dbbcn;
      }
      kmon=0;

      sprintf(outbuf,"synth=%d,s%d",1+ilo/2,1+ilo%2);

      if(lcl.output.state.known)
          synthesizer_output_2_dbbc3(outbuf,&lcl);

      if(lcl.freq.state.known)
          synthesizer_freq_2_dbbc3(outbuf,&lcl);

      if(2==lcl.check.check)
          strcat(outbuf,";mod cw;refs 1;ref 10;refdb 1;refdiv 0;off 0");

      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;
dbbcn:
      ip[0]=9;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("dbbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }

      dbbc3_synthesizer_dis(command,itask,ip,ilo,0,kmon,kcheck);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"dm",2);
      if(-102==ierr || -103==ierr || -307 == ierr || (-300 < ierr && ierr < -201 && -204 != ierr))
        memcpy(ip+4,lo3_key[ilo]+1,2);
      return;
}
