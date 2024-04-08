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
/* rdbe_data_send data structures */

struct rdbe_data_send_cmd {
  struct {
    int status;
    struct m5state state;
  }  status;
  struct {
    char start[18];
    struct m5state state;
  }  start;
  struct {
    char end[18];
    struct m5state state;
  }  end;
  struct {
    int delta;
    struct m5state state;
  }  delta;
};
struct rdbe_data_send_mon {
  struct {
    char  dot[18];
    struct m5state state;
  }  dot;
  struct {
    int delta_start;
    struct m5state state;
  }  delta_start;
  struct {
    int delta_stop;
    struct m5state state;
  }  delta_stop;
};
