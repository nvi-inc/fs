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
/* mk4vcd.c make list of vc detectors needed for Mark IV rack */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void mk4vcd(itpis)
int itpis[14];
{
  int vc,i;

  for (i=0;i<64;i++) {
    if ((i<32 && (shm_addr->form4.enable[0] & (1<<i))) ||
	(i>31 && (shm_addr->form4.enable[1] & (1<<(i-32))))) {
      vc=shm_addr->form4.codes[i]&0xF;
      if(-1 < vc && vc <14)
	itpis[vc]=1;
    }
  }
}
