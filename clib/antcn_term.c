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
#include <stdlib.h>
#include <stdio.h>

static int first=1;
static int value=-1;

antcn_term(out)
int *out;
{
  char *term;

  if(first) {
    term=getenv("FS_ANTCN_TERMINATION");
    if(term) {
      value=10;
      if(1!=sscanf(term,"%d%",&value))
	value=10;
      else if(value<0)
	value=10;
    }
    first=0;
  }

  *out=value;

  return 0;
}
