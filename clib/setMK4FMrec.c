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

setMK4FMrec(val,ip)
int val;
int ip[5];
{

  short int buff[80];
  int iclass, nrec;

  iclass=0;
  nrec=0;

  buff[0]=9;
  memcpy(buff+1,"fm",2);
  buff[2]=0;

  if(val == 1)
    strcpy((char *) (buff+2),"/rec 1");
  else
    strcpy((char *) (buff+2),"/rec 0");
  cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
  
  ip[0]=iclass;
  ip[1]=nrec;
  skd_run("matcn",'w',ip);
  skd_par(ip);
  if(ip[2] < 0) return;
  cls_clr(ip[0]);
}

