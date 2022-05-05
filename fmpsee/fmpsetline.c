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
#include <unistd.h>
#include <string.h>

int fmpsetline_(dcb,error,position)

FILE **dcb;
int *error;
int *position;

{
  int readstr();
  int i;

  *error = 0;

  *error = fseek(*dcb,0L,SEEK_SET);
  if (*error <0) return(*error);

  i=0;
  while (i < *position) {
    i++;
    *error = readstr(dcb);
    if (*error < 0) return(*error);
  }
  return(i);
}

int readstr(dcb)

  FILE **dcb;
{
  int i,c;

  i = 0;
  c = fgetc(*dcb);
  while ((c !=EOF) && (c !='\n')) {
    c = fgetc(*dcb);
  }

  if (c == EOF) {
    i = -1;
  }
 
  return(i);
}
