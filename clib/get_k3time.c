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
/* get time setting information from k4con */

#include <memory.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"

void get_k3time(centisec,fm_tim,ip)
int centisec[2];
int fm_tim[6];
int ip[5];                          /* ipc array */
{
  int year, ms, ilen, icount, ileap, it[6], iyrctl_fs;
  char buf[30];

  ib_req11(ip,"f3",19,"DATA=TIME");

  skd_run("ibcon",'w',ip);
  skd_par(ip);
  if(ip[2] <0) return;

  ilen=sizeof(buf);
  ib_res_ascii(buf,&ilen,ip);
  ib_res_time(centisec,ip);

  cls_clr(ip[0]);
  ip[0]=0;

  icount=sscanf(buf+2,"%2d%3d%2d%2d%2d.%3d",
		&year,fm_tim+4,fm_tim+3,fm_tim+2,fm_tim+1,&ms);

  rte_time(it,it+5);
  if(it[5]%100==0&&year==99)
    iyrctl_fs=it[5]-10-it[5]%10;
  else if(it[5]%100==99&&year==0)
    iyrctl_fs=it[5]+10-it[5]%10;
  else
    iyrctl_fs=it[5]-it[5]%10;

  fm_tim[5]=iyrctl_fs-iyrctl_fs%100+year;

  if(ms >=995) {
    fm_tim[0]=0;
    if(++fm_tim[1]>59) {
      fm_tim[1]=0;
      if(++fm_tim[2]>59) {
	fm_tim[2]=0;
	if(++fm_tim[3]>23) {
	  fm_tim[3]=0;
	  fm_tim[4]++;
	  ileap=fm_tim[5]%4 == 0 && (fm_tim[5]%100 !=0 || fm_tim[5]%400 ==0);
	  if((ileap && fm_tim[4] >366)||
	     (!ileap && fm_tim[4] >365)) {
	    fm_tim[4]=1;
	    fm_tim[5]++;
	  }
	}
      }
    }
  } else
    fm_tim[0]=(ms+5)/10;

}
