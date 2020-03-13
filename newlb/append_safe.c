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

append_safe( dest, src, n)
     char *dest; /* destination buffer, NULL terminated on entry */
     char *src;  /* source string, NULL terminated on entry */
     size_t n;   /* total sizeof(dest) from dest[0] */
     /* returns: zero if there was no problem,
      *          positive number of characters that won't fit otherwise
      */
{
  size_t s,d,o,m;
  
  s=strlen(src)+1;           /* space required for src */
  d=strlen(dest)+1;          /* space used in dest */
  o=n-d;                     /* space open in dest */
  m=(s<o)?s:o;               /* number to copy */
  strncpy(dest+d-1,src,m);
  if(m<s) {
    dest[n-1]=0;             /* NULL terminate when too long to fit */
    return s-m;
  }
  return 0;
}
