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
#define MAX_STRING  256

void nohelp_(infile,ierr,inum,len)
char *infile;
int *ierr;
int *inum;
int len;
{
  char string[MAX_STRING+1],*s1;
  FILE *idum;
  int freq,system();
  char outbuf[80];

  *ierr=0;
  if (len > MAX_STRING) {
    *ierr=-2;
    return;
  }

  s1=strcpy(string,infile,len);
  string[len]='\0';

  strcpy(outbuf[0],"ls /usr2/fs/help/");
  strcat(outbuf,string);
  strcat(outbuf,".* | wc -l > LS.NUM");

  freq = system(outbuf);

  idum=fopen("LS.NUM","r");
  *ierr=fscanf(idum,"%d",inum);
  fclose(idum);
  unlink("LS.NUM");

}
