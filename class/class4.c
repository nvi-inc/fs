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
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

main()
{
  int i;

  setup_ids();
  printf(" class_count %d\n",shm_addr->class_count);

  printf(" iclbox %d iclopr %d \n",shm_addr->iclbox,shm_addr->iclopr);

  for (i=0;i<MAX_CLS;i++)
     if(shm_addr->nums[i]!=0)
     printf(" class %d nums %d\n",i+1,shm_addr->nums[i]);

}
