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
/* mk5 data_check data structures */

struct scan_check_mon {

  /* command M5a and m5B parameters */

  struct {
    int scan;
    struct m5state state;
  } scan;
  struct {
    char label[65];
    struct m5state state;
  } label;
  struct {
    struct m5time start;
    struct m5state state;
  } start;
  struct {
    struct m5time length;
    struct m5state state;
  } length;
  struct {
    long long missing;
    struct m5state state;
  } missing ;

  /* m5a parameters */

  struct {
    char mode[33];
    struct m5state state;
  } mode;
  struct {
    char submode[33];
    struct m5state state;
  } submode ;
  struct {
    float rate;
    struct m5state state;
  } rate;

  /* m5b parameters */
  
  struct {
    char type[33];
    struct m5state state;
  } type;
  struct {
    int code;
    struct m5state state;
  }  code ;
  struct {
    float total;
    struct m5state state;
  } total;
  struct {
    char error[33];
    struct m5state state;
  } error;

};
