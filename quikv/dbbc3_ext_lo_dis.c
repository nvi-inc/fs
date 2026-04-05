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
/* dbbc3 ext_lo display */

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

void dbbc3_ext_lo_dis(command,itask,ip,itable,options)
struct cmd_ds *command;
int itask;
int ip[5];
int itable;
int options;
{
      char output[MAX_OUT];
      int out_class=0;
      int out_recs=0;
      int ierr=0;
      int count, i;

      static char *lo3_key[ ]={"loa","lob","loc","lod","loe","lof","log","loh"};
#define NLO3_KEY sizeof(lo3_key)/sizeof( char *)

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      if(itable>=0 && itable <shm_addr->dbbc3_ext_lo.count) {
          int ilo=shm_addr->dbbc3_ext_lo.table[itable].ifc;
          if (ilo >=0 && ilo <NLO3_KEY)
              strcat(output,lo3_key[ilo]);
          else if(-1==ilo)
              strcat(output,"all");
      }

      count=1;
      while( count>= 0) {
          if (count > 0) strcat(output,",");
          count++;
          dbbc3_ext_lo_enc(output,&count,&shm_addr->dbbc3_ext_lo.table,itable);
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

      return;

error:
      ip[0]=0;
      ip[1]=0;
 error2:
      ip[2]=ierr;
      memcpy(ip+3,"do",2);
      return;
}
