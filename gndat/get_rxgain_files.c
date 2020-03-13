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
#include <sys/types.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

#define MAXRX MAX_RXGAIN

int get_rxgain();

get_rxgain_files(directory,rxgain,names,ierr,work)
     char *directory;
struct rxgain_ds rxgain[];
char names[MAXRX][256], *work;
     int *ierr;
{
  
  char outbuf[200],pid[10];
  int freq, icount, i;
  FILE *idum;

  strcpy(outbuf,"ls ");
  strcat(outbuf,directory);
  strcat(outbuf,"/*.rxg");

  if(work[0]!= 0 &&strcmp(work,"0")!=0) {
    strcat(outbuf,".work.");
    strcat(outbuf,work); 
  } 
  
  strcat(outbuf," > /tmp/LS.NUM 2> /dev/null");
  
  freq = system(outbuf);
  
  if(freq!=0)
    {
      printf("System call to do ls on .rxg files failed\n");
      exit(0);
    }
  idum=fopen("/tmp/LS.NUM","r");
  unlink("/tmp/LS.NUM");

  icount=0;
  while(-1!=fscanf(idum,"%s",outbuf)){
    if(icount++ < MAX_RXGAIN) { 
      *ierr=get_rxgain(outbuf,&rxgain[icount-1]);
      strncpy(names[icount-1],outbuf,min(sizeof(names[icount-1]),strlen(outbuf))+1); 
    } else 
      *ierr=-999; 
    if(*ierr!=0) {
      if(*ierr == -715) {
        printf("too many tcal table entires, max is %d, file was %s\n",
          MAX_TCAL,outbuf);
      } else
        printf(" ierr = %d on %s\n",*ierr,outbuf);
      return -1;
    }
  }
  *ierr=0;
  return icount;

}
