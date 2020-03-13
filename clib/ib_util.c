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
/* ib or k4ib utilities */

#include <string.h>

#define MAX_BUF 512

ib_req1(ip,device)
int ip[5];
char device[2];
/* read ASCII */
{
  short int buffer[2];

  buffer[0]=1;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}

ib_req2(ip,device,ptr)
int ip[5];
char device[2];
char ptr[];
/* write ASCII */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=2;
  memcpy(buffer+1,device,2);
  nch=strlen(ptr);
  nch=nch>MAX_BUF-2? MAX_BUF-2:nch;
  memcpy(buffer+2,ptr,nch);

  cls_snd(ip+0,buffer,4+nch);
  ip[1]++;
}

ib_req3(ip,device)
int ip[5];
char device[2];
/* read binary */
{
  short int buffer[2];

  buffer[0]=3;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}

ib_req4(ip,device,ptr,n)
int ip[5];
char device[2];
char ptr[];
int n;
/* write binary */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=4;
  memcpy(buffer+1,device,2);
  memcpy(buffer+2,ptr,n);

  cls_snd(ip+0,buffer,4+n);
  ip[1]++;
}

ib_req5(ip,device,ilen)
int ip[5];
char device[2];
int ilen;
/* read ASCII with a max length */
{
  short int buffer[3];

  buffer[0]=5;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;

  cls_snd(ip+0,buffer,6);
  ip[1]++;
}

ib_req6(ip,device,ilen)
int ip[5];
char device[2];
int ilen;
/* read BINARY with a max length */
{
  short int buffer[3];

  buffer[0]=6;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;

  cls_snd(ip+0,buffer,6);
  ip[1]++;
}

ib_req7(ip,device,ilen,ptr)
int ip[5];
char device[2];
int ilen;
char ptr[];
/* write ASCII, read ASCII with a max length */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=7;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;
  nch=strlen(ptr);
  nch=nch>MAX_BUF-3? MAX_BUF-3:nch;
  memcpy(buffer+3,ptr,nch);

  cls_snd(ip+0,buffer,6+nch);
  ip[1]++;
}

ib_req8(ip,device,ilen,ptr)
int ip[5];
char device[2];
int ilen;
char ptr[];
/* write ASCII, read BINARY with a max length */
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=8;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;
  nch=strlen(ptr);
  nch=nch>MAX_BUF-3? MAX_BUF-3:nch;
  memcpy(buffer+3,ptr,nch);

  cls_snd(ip+0,buffer,6+nch);
  ip[1]++;
}

ib_req9(ip,device)
int ip[5];
char device[2];
/* bus status */
{
  short int buffer[2];

  buffer[0]=9;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}
ib_req10(ip,device)
int ip[5];
char device[2];
/* poll for SRQ */
{
  short int buffer[2];

  buffer[0]=10;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}

ib_req11(ip,device,ilen,ptr)
int ip[5];
char device[2];
int ilen;
char ptr[];
/* write ASCII, read ASCII with a max length and get time*/
{
  short int buffer[MAX_BUF];
  int nch;

  buffer[0]=11;
  memcpy(buffer+1,device,2);
  buffer[2]=ilen;
  nch=strlen(ptr);
  nch=nch>MAX_BUF-3? MAX_BUF-3:nch;
  memcpy(buffer+3,ptr,nch);

  cls_snd(ip+0,buffer,6+nch);
  ip[1]++;
}
ib_req12(ip,device)
int ip[5];
char device[2];
/* device clear */
{
  short int buffer[2];

  buffer[0]=12;
  memcpy(buffer+1,device,2);

  cls_snd(ip+0,buffer,4);
  ip[1]++;
}


ib_res_ascii(out,max,ip)
char *out;
int *max;
int ip[5];
{
  short int buffer[MAX_BUF];
  int nch,idum;

  if(ip[1]>0) {
    nch=cls_rcv(ip[0],buffer,MAX_BUF,&idum,&idum,0,0);
    *max=*max-1;
    *max=*max>nch-2? nch-2: *max;
    memcpy(out,buffer+1,*max);
    out[*max]=0;
    *max=nch-2;
    ip[1]--;
  }
}
ib_res_bin(out,max,ip)
char *out;
int ip[5];
int *max;
{
  short int buffer[MAX_BUF];
  int nch,idum;

  if(ip[1]>0) {
    nch=cls_rcv(ip[0],buffer,MAX_BUF,&idum,&idum,0,0);
    *max=*max>nch-2? nch-2: *max;
    memcpy(out,buffer+1,*max);
    *max=nch-2;
    ip[1]--;
  }
}
ib_res_time(centisec,ip)
int centisec[2];
int ip[5];
{
  short int buffer[MAX_BUF];
  int nch,idum;

  if(ip[1]>0) {
    nch=cls_rcv(ip[0],buffer,MAX_BUF,&idum,&idum,0,0);
    memcpy(centisec,buffer,2*sizeof(int));
    ip[1]--;
  }
}





