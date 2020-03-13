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
#include <stdio.h>

void
#ifdef F2C
copen_
#else
copen
#endif
(FILE **fp, char *filename, int len)
/* copen opens the file specified by filename
 * the file is opened for reading and writing
 * the file is created if doesn't exist
 * if it already exists, it is truncated to zero length
 * the file pointer is positioned to the beginning of the file
 * on return, *fp is zero if there was an error, non-zero othewise
	Last change:  JG   17 Oct 2006    2:00 pm
 */
{
  *fp=fopen(filename,"w+");
  return;
}

int
#ifdef F2C
cclose_
#else
cclose
#endif
(FILE **fp, char * clabtyp,int len)
/* cclose returns 0 if there was no error, non-zero otherwise */
{
  fprintf(*fp,"showpage\n");
  fprintf(*fp,"%%Trailer\n");
  return fclose(*fp);
}


