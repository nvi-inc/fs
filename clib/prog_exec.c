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
#include <stdio.h>	/* standard I/O header file */
#include <sys/types.h>	/* standard data types definitions */
#include <string.h>    /* shared memory IPC header file */
#include <stdlib.h>
#include <unistd.h>

void prog_exec( name)
char	name[5];
{
    int chpid,i;
    char string[6], *s1;

    s1=memcpy( string, name, 5);
    string[5]='\0';
    switch(chpid=fork()){
      case -1:
        fprintf( stderr,"fork failed for %s\n", string);
        exit( -1);
      case 0:
        i=execlp(string, string, (char *) 0);
        fprintf( stderr,"exec failed on %s\n", string);
        fflush( stderr);
        _exit(-2);
    }
    return;
}
