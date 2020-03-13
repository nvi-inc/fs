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

int fmpwritestr_(dcb,error,cbuf,len)

  FILE **dcb;
  char *cbuf;
  int *error,len;
{
  int i,c;

  *error = 0;

  for (i=0; i < len; i++) {
    c = cbuf[i];
    if (EOF == fputc(c,*dcb)) {
      *error=-1;
      return(*error);
    }
  }

  if (EOF == fputc('\n',*dcb)) {
    *error=-2;
    return(*error);
  }

  return(len);
}
