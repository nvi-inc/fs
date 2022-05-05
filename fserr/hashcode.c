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
#include <memory.h>
#include <stdio.h>

#include "fserr.h"

/*                                                                 */
/*  HASHCODE is the hash code to find the potential position in    */
/*  the array. Potential position because this code does not look  */
/*  for a conflict, it is just the hash code.                      */
/*                                                                 */

/*                                                                 */
/*  HISTORY:                                                       */
/*  WHO  WHEN    WHAT                                              */
/*  gag  920917  Created.                                          */
/*                                                                 */

struct entrystruc{
  char buf[2];
  int off;
};

void hashcode(entry, hash)
struct entrystruc *entry;
int *hash;

{
  int i;
  int itemp;
  char dig[3];

/*                                                                 */
/*  Use the uppercase mnemonic characters of the error message as  */
/*  a starting point for the hash. Then use the error numbers to   */
/*  get an offset to the starting point.                           */
/*                                                                 */

  *hash=((abs((*entry).buf[0]-65))/2)*100;
  *hash+=(abs((*entry).buf[1]-65))*10;
  *hash+= abs((*entry).off);
  if (*hash >= MAXERRORS) *hash=*hash%MAXERRORS;

}
