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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

echo_out(rw,bin,dev,buffer,buflen)
int rw, bin, dev, buflen;
unsigned char buffer[];
{
  char echo[512-sizeof("98001000000#ibcon#")];
  int inext,iout;

/*  printf("echo_out: rw %c bin %d dev %d buflen %d\n",rw,bin,dev,buflen);
*/

  if(rw == 'r')
    sprintf(echo,"<%d=",dev);
  else if(rw == 'w')
    sprintf(echo,"[%d=",dev);
  else if(rw == 'c')
    sprintf(echo,"{%d=",dev);

  if(bin==0) {
    for(inext=strlen(echo),iout=0;inext<sizeof(echo)-8 && iout <buflen;iout++) {
      if(buffer[iout] == '\\') {
	echo[inext++]='\\';
	echo[inext++]='\\';
      } else if(buffer[iout] == '\r') {
	echo[inext++]='\\';
	echo[inext++]='r';
      } else if(buffer[iout] == '\n') {
	echo[inext++]='\\';
	echo[inext++]='n';
      } else if(!isprint(buffer[iout])) {
	sprintf(echo+inext,"\\x%2.2x",buffer[iout]);
	inext+=4;
      } else
	echo[inext++]=buffer[iout];
    }
  } else {
    for(inext=strlen(echo),iout=0;inext<sizeof(echo)-5 && iout <buflen;
	iout++) {
      sprintf(echo+inext,"%2.2x,",buffer[iout]);
      inext+=3;
    }
    inext--;
  }

  if(iout>=buflen) 
    if(rw == 'r')
      echo[inext++]='>';
    else if(rw == 'w')
      echo[inext++]=']';
    else if(rw == 'c')
      echo[inext++]='}';
  else
    echo[inext++]='\\';
  
  echo[inext++]=0;
  logit(echo,0,NULL);
}



