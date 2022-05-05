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
/* lbaifpd.c make list of ifp detectors needed for LBA rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void lbaifpd(itpis)
int itpis[2*MAX_DAS];
{
   int i;

   for(i=0; i<2*shm_addr->n_das; i++)
	if (shm_addr->das[i/2].ifp[i%2].track[0] != -1 ||
	    shm_addr->das[i/2].ifp[i%2].track[1] != -1)
		itpis[i] = 1;
}

