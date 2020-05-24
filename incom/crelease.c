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
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void crelease_()
{
  int i,j;

#define xstr(a) str(a)
#define str(a) #a
#define RELV xstr(RELEASE)
#define FC1V xstr(FC1)

  strncpy(shm_addr->sVerRelease_FS,RELV,sizeof(shm_addr->sVerRelease_FS));
  shm_addr->sVerRelease_FS[sizeof(shm_addr->sVerRelease_FS)-1]=0;
  j=strlen(shm_addr->sVerRelease_FS);
  for(i=j;i<sizeof(shm_addr->sVerRelease_FS)-1;i++)
    shm_addr->sVerRelease_FS[i]=' ';

  strncpy(shm_addr->fortran,FC1V,sizeof(shm_addr->fortran));
  shm_addr->fortran[sizeof(shm_addr->fortran)-1]=0;
  j=strlen(shm_addr->fortran);
  for(i=j;i<sizeof(shm_addr->fortran)-1;i++)
    shm_addr->fortran[i]=' ';
}
