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
/* lognm.c print log name to standard output */

#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

main(argc, argv)
int argc;
char **argv;
{
    void setup_ids();
    char log[9];
    int i;

    setup_ids();

    if ( 1 != nsem_take("fs   ",1)) {
         exit( -1);
    }

    memcpy(log, shm_addr->LLOG, 8);
    log[8]=0;

    for(i=7;0<=i;i--) {
      if(log[i]!=' ')
	goto print;
      log[i]=0;
    }

  print:
    printf("%s\n",log);

    exit( 0);
}
