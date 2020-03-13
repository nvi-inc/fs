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
/* mk5 dot data structures */

struct dot_mon {
  struct {
    char time[33];
    struct m5state state;
  } time ;
  struct {
    char status[33];
    struct m5state state;
  } status ;
  struct {
    char FHG_status[33];
    struct m5state state;
  } FHG_status ;
  struct {
    char OS_time[33];
    struct m5state state;
  } OS_time ;
  struct {
    char DOT_OS_time_diff[33];
    struct m5state state;
  } DOT_OS_time_diff ;
};
