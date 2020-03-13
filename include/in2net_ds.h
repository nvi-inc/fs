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
/* mk5 in2net data structures */

struct in2net_cmd {
  struct {
    int control;
    struct m5state state;
  } control;
  struct {
    char destination[33];
    struct m5state state;
  } destination ;
  struct {
    char options[33];
    struct m5state state;
  } options ;  
  char last_destination[33];
};

struct in2net_mon {
  struct {
    char status[33];
    struct m5state state;
  } status;
  struct {
    long long received;
    struct m5state state;
  } received;
  struct {
    long long buffered;
    struct m5state state;
  } buffered;
};
