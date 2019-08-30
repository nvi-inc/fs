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
/* logitf

   logitf formats a FS monitor command response and sends the
   buffer to ddout.
*/

#include <string.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/fscom.h"

void cls_snd();
void pname();
void rte_time();

logitf(msg)
char *msg;           /* a message to be logged, NULL if none */
{
  char buf[MAX_CLS_MSG_BYTES+1];    /* Holds the complete log entry */
  char name[5];     /* The name of our main program */
  int it[6],ip1,ip2,l;
 
/* First get the time and put dddhhmmss into the log entry.
*/
  rte_time(it,&it[5]);
  buf[0]='\0';
  int2str(buf,it[5],-4,1);
  strcat(buf,".");
  int2str(buf,it[4],-3,1);
  strcat(buf,".");
  int2str(buf,it[3],-2,1);
  strcat(buf,":");
  int2str(buf,it[2],-2,1);
  strcat(buf,":");
  int2str(buf,it[1],-2,1);
  strcat(buf,".");
  int2str(buf,it[0],-2,1);

  strcat(buf,"/");
  if(msg!=NULL) {
    int n;
    int bufl=strlen(buf);
    int msgl=strlen(msg);
    n=sizeof(buf)-bufl-1;
    if(msgl < n)
      n=msgl;
    memcpy(buf+bufl,msg,n);
    buf[bufl+n]=0;
  }

/* Send the complete log entry to ddout via class.
*/
  memcpy(&ip1,"fs",2);
  memcpy(&ip2,"  ",2);

/* for testing, send to output PLUS class */
/*  fprintf(stdout,"%s\n",buf); */
  cls_snd(&shm_addr->iclbox,buf,strlen(buf),ip1,ip2);
}
