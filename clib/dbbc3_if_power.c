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
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

double dbbc3_if_power(unsigned counts, int como)
{
  double fact;
  if(como < 0 || como >= MAX_DBBC3_IF)
    fact=1.0;  /*defensive, a bad value is really bad */
  else
    fact=19000.0;
    //  fact=shm_addr->dbbc_if_factors[como];

  //   printf(" como %d fact %f counts %u pow %f\n",
  //   como,fact,counts,65535*pow(10.0,(((int)counts)-65535)/fact));
  return 65535*pow(10.0,(((int)counts)-65535)/fact);
}
