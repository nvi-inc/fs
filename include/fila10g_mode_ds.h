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
/* mk5b_mode data structures */

struct fila10g_mode_cmd {
  struct {
    unsigned int mask2;
    struct m5state state;
  } mask2;
  struct {
    unsigned int mask1;
    struct m5state state;
  } mask1;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
  struct {
    int disk;
    struct m5state state;
  } disk;
};

struct fila10g_mode_mon {
  struct {
    int clockrate;
    struct m5state state;
  } clockrate;
};
