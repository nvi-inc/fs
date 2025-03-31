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

#include <stdlib.h>
#include <sys/sysinfo.h>

void check_nprocs__()
{
  int avail=get_nprocs();

/* send warnings if not enough processors for display server */

  if(avail<2) {
    int conf=get_nprocs_conf();

      logit(NULL,993,"bo");
      logitn(NULL,994,"bo",conf);
      logit(NULL,995,"bo");
      logit(NULL,996,"bo");
  }
}
