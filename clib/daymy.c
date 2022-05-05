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
/* convert month, day of month to day of year */
int daymy(int year, int month, int day)
/* four digit year, Jan is month 1, first day of month is 1 */
{
  /*                    J  F  M  A  M  J  J  A  S  O  N  D */
  int month_days[ ] = {31,28,31,30,31,30,31,31,30,31,30,31};

  /* not Y2.1K compliant */
  if(year % 4 == 0)
    month_days[1] =  29;
  else
    month_days[1] =  28;

  if(month > 12)
    month = 13;  /* so month 13 and up is Jan next year */
  
  if(month > 1)  /* month 1 or less means day is already day of year */
    while(--month)
      day += month_days[month-1];

  return day;
}

