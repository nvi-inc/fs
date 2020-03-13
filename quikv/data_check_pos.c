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
#include <string.h>

#define BUFSIZE 512

int data_check_pos(ip)
int ip[5];
{

  int out_class;
  int out_recs, ierr, icount;
  double pos;
  char outbuf[BUFSIZE];
  char inbuf[BUFSIZE];
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char *ptr;
  int class, nrecs;
  int i;

  out_recs=0;
  out_class=0;
    
  strcpy(outbuf,"scan_set = : -1000000 ;\n");
  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
  out_recs++;
  
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("mk5cn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) {
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    return -1;
  }

  cls_clr(ip[0]);
  ip[0]=ip[1]=0;
  ip[0]=ip[1]=ip[2]=0;
  return 0;

  error:
    cls_clr(ip[0]);
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"5d",2);
    return -1;
}
