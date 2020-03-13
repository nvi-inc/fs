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
#define MAX_LINE 256

int fmpread_(dcb,error,buf,len)
FILE **dcb;
char *buf;
int *error,*len;
{
  int clen,i;
  char *c;

  buf[0]=0;
  c = fgets(buf,*len,*dcb);

  clen=strlen(buf);
  buf[clen]=' ';
  if(clen>0 && buf[clen-1]=='\n')
    buf[--clen]=' ';
  else if(clen > 0){
    char ch=fgetc(*dcb);
    while (ch!= EOF && ch!= '\n')
      ch=fgetc(*dcb);
  }

  /* defense against DOS line terminaton */

  if(clen>0 && buf[clen-1]=='\r') {
    buf[--clen]=0;
  }

  if(c == NULL) {
    if(clen 	== 0)
      return -1;
  }
    return clen;
}
