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
/* mk5 disk2file data structures */

struct disk2file_cmd {
  struct {
    char scan_label[65];
    struct m5state state;
  } scan_label;
  struct {
    char destination[129];
    struct m5state state;
  } destination ;
  struct {
    char start[33];
    struct m5state state;
  } start ;
  struct {
    char end[33];
    struct m5state state;
  } end ;
  struct {
    char options[33];
    struct m5state state;
  } options ;  
};

struct disk2file_mon {

  /* common parameters */

  struct {
    char option[33];
    struct m5state state;
  } option;
  struct {
    long long start_byte;
    struct m5state state;
  } start_byte;
  struct {
    long long end_byte;
    struct m5state state;
  } end_byte;
  struct {
    char status[33];
    struct m5state state;
  } status;
  struct {
    long long current;
    struct m5state state;
  } current ;

  /* m5a parameters */

  struct {
    int scan_number;
    struct m5state state;
  } scan_number;

  /* m5b parameters */


};
