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
/* dbbc3 synthesizer display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 513

int logmsg_dbbc3();

void dbbc3_synthesizer_dis(command,itask,ip,ilo,options,kmon,kcheck)
struct cmd_ds *command;
int itask;
int ip[5];
int ilo;
int options;
int kmon;
int kcheck;
{
      struct dbbc3_synthesizer_cmd lclc;
      struct dbbc3_synthesizer_mon lclm;
      int kcom,i,ich, count;
      int ierr=0;
      char output[MAX_OUT];
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      int out_class=0;
      int out_recs=0;
      char inbuf[BUFSIZE];
      char inbuf2[BUFSIZE];

      static char *lo3_key[ ]={"loa","lob","loc","lod","loe","lof","log","loh"};
#define NLO3_KEY sizeof(lo3_key)/sizeof( char *)

      kcom= command->argv[1] != NULL &&
            *command->argv[1] == '?' && command->argv[2] == NULL;

      kcom= kcom || command->argv[0] != NULL &&
          *command->argv[0] == '?' && command->argv[1] == NULL;

      if (!kcom && !kmon) {
         ierr=logmsg_dbbc3(output,command,ip);
	 if(ierr!=0) {
	    ierr+=-450;
	    goto error2;
	 }
	 return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->dbbc3_synthesizer[ilo],sizeof(lclc));
      else {
	for (i=0;i<ip[1];i++) {
	  if ((nchars =
	       cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
	    if(i<ip[1]-1) 
	      cls_clr(ip[0]);
	    ierr =  -401;
	    goto error;
	  }
	  inbuf[nchars]=0;
	  memcpy(inbuf2,inbuf,sizeof(inbuf2));
          char *ptr=strrchr(inbuf,';');
          if(NULL!=ptr)
              *ptr=0;
          switch(i) {
              case 0:
              case 1:
              case 2:
              case 4:
              case 6:
              case 8:
              case 10:
              case 12:
                  ierr=0;
                  break;
              case 3:
                  ierr=dbbc3_2_synthesizer_freq(&lclc,inbuf);
                  break;
              case 5:
                  ierr=dbbc3_2_synthesizer_enable(&lclc,inbuf);
                  break;
              case 7:
                  ierr=dbbc3_2_synthesizer_atten(&lclm,inbuf);
                  break;
              case 9:
                  ierr=dbbc3_2_synthesizer_mode(&lclm,inbuf);
                  break;
              case 11:
                  ierr=dbbc3_2_synthesizer_lock(&lclm,inbuf);
                  break;
              default:
                  ierr=-404;
                  break;
          }
          if(ierr!=0) {
              if(i<ip[1]-1) 
                  cls_clr(ip[0]);
              if(ierr!=-404) {
                  ierr=-403;
                  logite(inbuf2,-402,"dm");
              }
              goto error;
          }
	}
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      if (ilo >=0 && ilo <NLO3_KEY)
          strcat(output,lo3_key[ilo]);

      count=1;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        dbbc3_synthesizer_enc(output,&count,&lclc);
      }

      if(!kcom) {
	count=0;
	while( count>= 0) {
	  if (count > 0) strcat(output,",");
	  count++;
	  dbbc3_synthesizer_mon(output,&count,&lclm);
	}
      }
      
      if(strlen(output)>0) output[strlen(output)-1]='\0';

send:
      for (i=0;i<5;i++)
          ip[i]=0;
      if(0==options) {
          cls_snd(&out_class,output,strlen(output),0,0);
          out_recs++;
      } else
          logit(output,0,NULL);

      ip[0]=out_class;
      ip[1]=out_recs;

      if(kcheck) {
          if(shm_addr->dbbc3_synthesizer[ilo].freq.state.known &&
             shm_addr->dbbc3_synthesizer[ilo].enable.state.known &&
             shm_addr->dbbc3_synthesizer[ilo].enable.enable==1) {
              if(shm_addr->dbbc3_synthesizer[ilo].freq.freq != lclc.freq.freq) {
                  logita(NULL,-611,"dm",lo3_key[ilo]+1);
                  ierr=-600;
              }
          }
          if(shm_addr->dbbc3_synthesizer[ilo].enable.state.known) {
              if(shm_addr->dbbc3_synthesizer[ilo].enable.enable != lclc.enable.enable) {
                  logita(NULL,-612,"dm",lo3_key[ilo]+1);
                  ierr=-600;
              }
          }
          if(lclm.mode.mode) {
              logita(NULL,-613,"dm",lo3_key[ilo]+1);
              ierr=-600;
          }
          if(1!=lclm.lock.lock) {
              logita(NULL,-614,"dm",lo3_key[ilo]+1);
              ierr=-600;
          }

          if(-600==ierr) {
              memcpy(ip+4,lo3_key[ilo]+1,2);
              goto error2;
          }
      }

      return;

error:
      ip[0]=0;
      ip[1]=0;
 error2:
      ip[2]=ierr;
      memcpy(ip+3,"dm",2);
      return;
}
