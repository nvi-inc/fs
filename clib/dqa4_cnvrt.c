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
/* parity command utilities to support vlba drives and racks */

#include <string.h>
#include <sys/types.h>
#include <stdio.h>

void dqa4_cnvrt(ibuf,jfrms,jperr,jsync,ierr)
char *ibuf;               /* string to decode */
int jfrms[2];            /* returned frames errors */
int jperr[2];            /* returned parity errors */
int jsync[2];            /* returned re-sync counts */
int *ierr;
{
  int jrsyn[2];
  int jnsyn[2];
  int jcrc[2];
  int icount;

  icount=sscanf(ibuf,"dqa %x %x %x %x %x %x %x %x %x %x",
		jfrms+0,jperr+0,jnsyn+0,jrsyn+0,jcrc+0,
		jfrms+1,jperr+1,jnsyn+1,jrsyn+1,jcrc+1);

  if(icount == 10)
    *ierr=0;
  else {
    icount=sscanf(ibuf,"dq %x %x %x %x %x %x %x %x %x %x",
		  jfrms+0,jperr+0,jnsyn+0,jrsyn+0,jcrc+0,
		  jfrms+1,jperr+1,jnsyn+1,jrsyn+1,jcrc+1);
    if(icount == 10)
      *ierr=0;
    else
      *ierr=-1;
  }

  jsync[0]=jrsyn[0];
  jsync[1]=jrsyn[1];

  return;
}

