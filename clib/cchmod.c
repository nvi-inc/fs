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
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>

void cchmod(filename,permissions,ilen,error,flen)
char *filename;
int *permissions;
int *ilen;
int *error;
int flen;
{
    char chname[65];
    int i;

    *error = 0;
    if ((flen < 0) || (flen > 64)||(*ilen < 0)||(*ilen > flen)){
      *error = -1;
      return;
    }

    strncpy(chname,filename,flen);
    chname[flen]=0;
    i = *ilen-1;
    while (i >=0 && chname[i] == ' ')
      i=i-1;
    chname[i+1] = '\0';

    chmod(chname,*permissions);
}
