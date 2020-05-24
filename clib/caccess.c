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
#include <unistd.h>
#include <errno.h>
#include <string.h>

void caccess(filename,mode,error,perror,flen,mlen)
char *filename;
char *mode;
int *error;
int *perror;
int flen;
int mlen;
{
    char cname[65];
    int i,cmode;

    *error = 0;
    *perror = 0;

    if (flen < 0 || flen > sizeof(cname)-1){
      *error = -1;
      return;
    }

    if(mlen < 1) {
        *error= -2;
        return;
    }

    memcpy(cname,filename,flen);
    cname[flen]=0;
    for (i=flen-1;i>-1 && ' '==cname[i];i--)
        cname[i]=0;

    cmode=0;
    if(' '==mode[0])
        cmode=F_OK;

    for (i=0;i<mlen;i++) {
        switch (mode[i]) {
            case 'r':
            case 'R':
                if(F_OK==cmode)
                    cmode=0;
                cmode |= R_OK;
                break;
            case 'w':
            case 'W':
                if(F_OK==cmode)
                    cmode=0;
                cmode |= W_OK;
                break;
            case 'x':
            case 'X':
                if(F_OK==cmode)
                    cmode=0;
                cmode |= X_OK;
                break;
            case ' ':
                break;
            default:
                *error = -3;
                return;
        }
    }
    if(access(cname,cmode)) {
        *error=-4;
        *perror=errno;
    }
}
