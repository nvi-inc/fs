/*
 * Copyright (c) 2025 NVI, Inc.
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
/* initialization for "C" shared memory area */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <limits.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

char *getenv_DBBC3( char *env, int *actual, int *nominal, int *error, int options);

/* initialized items that cannot be set before control files are read */

void cshm_init2()
{
  int i,j;
  static int time_included = -1;
  static int epoch_inserted = -1;
  char *ptr;


  if(0>time_included) {
      int actual, error;
      ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_CORE3H_TIME_INCLUDED",&actual,NULL,&error,1);
      if(0==error)
          time_included=actual;
      else
          time_included=0;
  }

  if(0>epoch_inserted) {
      int actual, error;
      ptr=getenv_DBBC3("FS_DBBC3_MULTICAST_CORE3H_VDIF_EPOCH_INSERTED",&actual,NULL,&error,1);
      if(0==error)
          epoch_inserted=actual;
      else
          epoch_inserted=0;
  }

  shm_addr->dbbc3_tsys_data.iping=0;
  shm_addr->dbbc3_tsys_data.epoch_inserted=epoch_inserted;
  for(i=0;i<2;i++) {
      shm_addr->dbbc3_tsys_data.data[i].last=0;
      for(j=0;j<MAX_DBBC3_IF;j++) {
          shm_addr->dbbc3_tsys_data.data[i].ifc[j].lo=-1.0;
          shm_addr->dbbc3_tsys_data.data[i].ifc[j].delay=UINT_MAX;
          shm_addr->dbbc3_tsys_data.data[i].ifc[j].time_included=time_included;
          shm_addr->dbbc3_tsys_data.data[i].ifc[j].time_error=-1000000;
          shm_addr->dbbc3_tsys_data.data[i].ifc[j].vdif_epoch= -1;
          shm_addr->dbbc3_tsys_data.data[i].ifc[j].time = 0;
      }
      for(j=0;j<MAX_DBBC3_BBC;j++) {
          shm_addr->dbbc3_tsys_data.data[i].bbc[j].freq=UINT_MAX;
          shm_addr->dbbc3_tsys_data.data[i].bbc[j].tsys_lsb=-9e20;
          shm_addr->dbbc3_tsys_data.data[i].bbc[j].tsys_usb=-9e20;
      }
  }

  return;
}
