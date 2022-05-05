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
/* bsfo2vars.c - interpret lba ifp sampler names */

#include <sys/types.h>
#include <string.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

int bsfo2vars(bs, ifp, sb, b, fo)
char *bs;
int *ifp;
int *sb;
int *b;
int *fo;
{
  int code;
  char *pos;
  char digits[]="0123456789";
  char sidebands[]="ul";
  char bits[]="sm";

  *fo = 0;

  if (bs == NULL)
    return -2;

  if (strcmp(bs,"0")==0)
    return -1;

  if (strcmp(bs,"")==0)
    return -3;

/*decode bit-stream "+" fan-out */

  while(*bs != 0 && *bs==' ')
    bs++;

  pos=strchr(digits,*bs);
  if(pos==NULL || *pos == '0')
    return -4;
  else
    *ifp=pos-digits-1;

  bs++;
  pos=strchr(sidebands,*bs);
  if(pos==NULL)
    return -4;
  *sb=pos-sidebands;

  bs++;
  pos=strchr(bits,*bs);
  if(pos==NULL)
    return -4;
  *b=pos-bits;

  bs++;
  if(*bs=='+') {
    bs++;
    pos=strchr(digits,*bs);
    if(pos==NULL)
      return -4;
    *fo=pos-digits;
    if(*fo>3)
      return -4;
    bs++;
  }

  if(*bs==' ') {
    bs++;
    while(*bs!=0&& *bs==' ')
      bs++;
    if(*bs !=0)
      return -4;
  } else if(*bs!=0)
    return -4;

/* got it ... return results */
  return 0;
}

char *vars2bsfo(bw,ifp,sb,b)
int bw, ifp, sb, b;
{
  static char array[7];

  sprintf(array,"%d",1+ifp);

  if(sb && bw < _32D00)
    strcat(array,"l");
  else
    strcat(array,"u");

  if(b && bw < _64D00)
    strcat(array,"m");
  else
    strcat(array,"s");

  if(bw >= _32D00)
    sprintf(array+strlen(array),"+%d",bw>_32D00?2*sb+b:sb);
  else
    sprintf(array+strlen(array),"+0");

  return array;
}
