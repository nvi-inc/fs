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

int find_next_noncomment(fp,buff,sbuff)
     FILE *fp;
     char buff[];
     int sbuff;
{  
  char check, *cptr;
  int i;

 start:
  check=fgetc(fp);
  while(check == '*' && check != EOF) {
    check=fgetc(fp);
    while(check != '\n' && check != EOF)
      check=fgetc(fp);
    if(check != EOF) {
      check=fgetc(fp);
    }
  }

  if (check == EOF)
    /* ended in comment */
    return -1;
  else if(ungetc(check, fp)==EOF)
    return -2;

  cptr=fgets(buff,sbuff,fp);
  if(cptr!=buff)
    return -3;

  if(strchr(buff,'\n')==NULL)
    return -4;

  for(i=0;i<strlen(buff);i++) {
    if(strchr(" \n\t",buff[i])==NULL) {
      return 0;
    }
  }
  
  goto start;
}
