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
/* fserr_cls.c - special buffer passing to/from "fserr"
   because we can't use class system here to avoid potential
   deadlock, - single buffer only 
*/

#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

void fserr_snd(char *buf, int nchars)
{

  if(nchars>sizeof(shm_addr->fserr_cls.buf))
    nchars=sizeof(shm_addr->fserr_cls.buf);

  memcpy(shm_addr->fserr_cls.buf, buf, nchars);
  shm_addr->fserr_cls.nchars=nchars;

  return;
}

int fserr_rcv(char *buf, int nchars)
{

  if(nchars > shm_addr->fserr_cls.nchars)
    nchars=shm_addr->fserr_cls.nchars;

  memcpy(buf, shm_addr->fserr_cls.buf, nchars);

  return nchars;
}
