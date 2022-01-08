/*
 * Copyright (c) 2020-2021 NVI, Inc.
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
/* cor3eh_mode data structures */

struct dbbc3_core3h_modex_cmd {
  int set;
  struct {
    unsigned int mask2;
    struct m5state state;
  } mask2;
  struct {
    unsigned int mask1;
    struct m5state state;
  } mask1;
  struct {
    int width;
    struct m5state state;
  } width;
  struct {
    int channels;
    struct m5state state;
  } channels;
  struct {
    int payload;
    struct m5state state;
  } payload;
  struct {
    int decimate;
    struct m5state state;
  } decimate;
  struct {
    int force;
    struct m5state state;
  } force;
  struct {
    int disk;
    struct m5state state;
  } disk;
  struct {
    int start;
    struct m5state state;
  } start;
};

struct dbbc3_core3h_modex_mon {
  struct {
    int clockrate;
    struct m5state state;
  } clockrate;
  struct {
    int splitmode;
    struct m5state state;
  } splitmode;
  struct {
    int vsi_input;
    struct m5state state;
  } vsi_input;
  struct {
    unsigned int mask4;
    struct m5state state;
  } mask4;
  struct {
    unsigned int mask3;
    struct m5state state;
  } mask3;
};
