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

#include <sys/time.h>
#include <unistd.h>

struct timeval   tp;
struct timezone  tzp;
struct tm        *tme;

int idate (month,day,year)

int *month, *day, *year;

{
      gettimeofday(&tp,&tzp);
      tme = gmtime(&tp.tv_sec);
      *month = tme->tm_mon + 1;
      *day   = tme->tm_mday;
      *year  = tme->tm_year;

}
