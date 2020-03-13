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
#include <memory.h>
#define NULLPTR (char *) 0

void wandwr_(port, buffer, buflen, error)

  int *buffer;
  int *port;
  int *buflen;
  int *error;

{
/*  printf("\nbuflen = %d\n",*buflen); printf("buffer = %x\n",buffer);*/ 

  *error = write(*port, buffer, *buflen); 
  if (*error < 0 ){
    printf(" error writing to port \n");
    perror("");
  } else if (*error != *buflen) {
    printf(" wrong number characters written to port\n");
    *error=-1;
  } else {
    *error=0;
  }
  return;
}
