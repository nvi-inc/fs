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
/* header file for rclcn response data structures */

#define RCLCN_RES_MAX_BUF  512

struct rclcn_res_buf {
  int class_fs;
  int count;
  int ifc;
  int nchars;
  unsigned char buf[ RCLCN_RES_MAX_BUF];
};

union pos_union {
  struct {
    int position;
    int posvar;
  } overall;
  struct {
    int num_entries;
    int position[8];
  } individual;
};
