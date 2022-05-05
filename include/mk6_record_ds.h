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
/* mk6_record data structures */

struct mk6_record_cmd {
  struct {
    /*  ####y###d##h##m##.##s\0 
        1234567890123456789012 */
    char action[22];
    struct m5state state;
  } action;
  struct {
    int duration;
    struct m5state state;
  } duration ;
  struct {
    int size;
    struct m5state state;
  } size;
  struct {
    char scan[33];
    struct m5state state;
  } scan;
  struct {
    char experiment[9];
    struct m5state state;
  } experiment;
  struct {
    char station[9];
    struct m5state state;
  } station;
  
};
struct mk6_record_mon {
  struct {
    char status[33];
    struct m5state state;
  } status ;
  struct {
    int group;
    struct m5state state;
  } group;
  struct {
    int number;
    struct m5state state;
  } number;
  struct {
    char name[33];
    struct m5state state;
  } name;
};
