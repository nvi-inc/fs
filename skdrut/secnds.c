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
/* 04.06.21 AEM adds #include <time.h> */

#include <time.h>
#include <sys/time.h>
#include <unistd.h>

extern struct timeval   tp;
extern struct timezone  tzp;
extern struct tm        *tme;

float secnds(offset)
float *offset;
{
      gettimeofday(&tp,&tzp);
      tme = gmtime(&tp.tv_sec);
      return((tme->tm_hour * 3600.0) + (tme->tm_min * 60.0) +
             (tme->tm_sec) + (*offset));
}
