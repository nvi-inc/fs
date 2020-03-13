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
/* mk6 scan_check data structures */

struct mk6_scan_check_mon {

  /* M6 scan check monitor parameters */

  struct {
    int scan;
    struct m5state state;
  } scan;
  struct {
    char label[65];
    struct m5state state;
  } label;
  struct {
    char type[33];
    struct m5state state;
  } type;
  struct {
    int code;
    struct m5state state;
  }  code ;
  struct {
    struct m5time start;
    struct m5state state;
  } start;
  struct {
    struct m5time length;
    struct m5state state;
  } length;
  struct {
    float total;
    struct m5state state;
  } total;
  struct {
    long long missing;
    struct m5state state;
  } missing ;
  struct {
    char error[33];
    struct m5state state;
  } error;

};
