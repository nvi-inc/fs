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
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_OUT 120
#define MAX_BUF 256

void logmatmsg(output,command,ip)
char *output;
struct cmd_ds *command;
int ip[5];
{
  char buff[MAX_BUF];

  int i, nchar, ilen, idum, icopy, nrec, cls_rcv();
  int iclass;
  void cls_clr();

  strcpy(output,command->name);
  strcat(output,"/");
  
  iclass=ip[0];
  nrec=ip[1];

  ip[0]=ip[1]=ip[2]=0;

  for (i=0;i<nrec;i++) {
    nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);

    ilen=strlen(output);
    if(i!=0 && ((MAX_OUT-(ilen+1))<(nchar-2)|| memcmp(buff+2,"ack",3)!=0)) {
      cls_snd(ip,output,strlen(output)-1,0,0);
      ip[1]++;
      strcpy(output,command->name);
      strcat(output,"/");
      ilen=strlen(output);
    }

    icopy=MAX_OUT-(ilen+1);
    icopy= icopy < (nchar-2) ? icopy : (nchar-2);

    memcpy(output+ilen,buff+2,icopy);
    output[ilen+icopy]=0;
    strcat(output,",");
  }

  
  cls_snd(ip,output,strlen(output)-1,0,0);
  ip[1]++;

  cls_clr(iclass);
  
  return;
}
