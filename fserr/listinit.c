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
#include <stdlib.h>
#include <unistd.h>
#include "fserr.h"

/*                                                                 */
/*  LISTINIT subroutine will read the file of the descriptor       */
/*  passed in and place the contents into the array for use by     */
/*  FSERR. Essentially, this is the initialization subroutine      */
/*  of the array for FSERR.                                        */
/*                                                                 */

/*                                                                 */
/*  HISTORY:                                                       */
/*  WHO  WHEN    WHAT                                              */
/*  gag  920917  Created.                                          */
/*                                                                 */

struct errorlst{
  char mnemonic[2];
  int ierr;
  char message[120];
};

void listinit(tdcb,list,file)
FILE *tdcb;
struct errorlst list[MAXERRORS];
char *file;
{

  int hashcount;
  int hash;
  int inum;
  char dquote[2];
  int errnum;
  char buffer[MAXSTR];
  int err;
  int next_line;

  struct {
    char buf[2];
    int off;
  } entryfs;

  next_line=1;
  while (fgets(buffer,MAXSTR,tdcb)!=NULL) {
    if(1!=(inum = sscanf(buffer,"%1s",dquote))) {
      printf("fserr: ERROR in control file, double quote, line %d, file %s\n",
	     next_line,file);
      exit(-1);
    }

    next_line++;
    if (fgets(buffer,MAXSTR,tdcb)==NULL) {
      printf("fserr: ERROR reading control file, mnemonic, line %d, file %s\n",
	     next_line,file);
      exit(-1);
    }
    
    if(2!=(inum = sscanf(buffer,"%2s%d",entryfs.buf,&entryfs.off))) {
      printf("fserr: ERROR in control file, mnemonic, line %d file %s\n",
	     next_line,file);
      exit(-1);
    }
    
    next_line++;
    if (fgets(buffer,MAXSTR,tdcb)==NULL) {
      printf("fserr: ERROR reading control file, message, line %d file %s\n",
	     next_line,file);
      exit(-1);
    }

    hashcode(&entryfs,&hash);

    hashcount = 0;
    while (list[hash].ierr!=0) {
      hash+=1;
      if (hash==MAXERRORS) 
        hash=0;
      hashcount+=1;
      if (hashcount==MAXERRORS) {
        printf("index table overflow!!!! oooooh, you've really done it now!\n");
        exit(-1);
      }
    }
    memcpy(list[hash].mnemonic,entryfs.buf,2);
    list[hash].ierr=entryfs.off;
    memcpy(list[hash].message,buffer,120);

    next_line++;
  }
}
