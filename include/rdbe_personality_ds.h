/*
 * Copyright (c) 2024 NVI, Inc.
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
/* RDBE personality data structures */

struct rdbe_personality_cmd {
  struct {
    char type[65];
    struct m5state state;
  } type;
  struct {
    char file[65];
    struct m5state state;
  } file;
};

struct rdbe_personality_mon {
  struct {
    char status[65];
    struct m5state state;
  } status;
  struct {
    int board;
    struct m5state state;
  } board;
  struct {
    int major;
    struct m5state state;
  } major;
  struct {
    int minor;
    struct m5state state;
  } minor;
  struct {
    int rcs;
    struct m5state state;
  } rcs;
  struct {
    char fpga[65];
    struct m5state state;
  } fpga;
};
