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

int fmpreadstr_(dcb,error,cbuf,len)
FILE **dcb;
char *cbuf;
int *error,len;
{
  int clen,i,s;
  char *c;

  cbuf[0]=0;
  c = fgets(cbuf,len,*dcb);

  clen=strlen(cbuf);
  if(clen>0 && cbuf[clen-1]=='\n') {
    cbuf[--clen]=0;
  } else if(clen>0) {
    while('\n' !=(s = fgetc(*dcb)))
      if(s==EOF) {
	c=NULL;
	break;
      }
  }

  /* defense against DOS line terminaton */

  if(clen>0 && cbuf[clen-1]=='\r') {
    cbuf[--clen]=0;
  }

  if(c == NULL) {
    if(feof(*dcb)) {
      *error = 0;
    } else {
      *error=-1;
    }
    if(clen 	== 0) {
      for (i=clen;i<len;i++)
	cbuf[i]=' ';
      return -1;
    }
  }
  for (i=clen;i<len;i++)
    cbuf[i]=' ';

    return clen;
}
