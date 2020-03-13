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
/* mk5 disk_serial data structures */

#define MK5_DISK_SERIAL_MAX 16
#define MK5_DISK_SERIAL_BYTES 33

struct disk_serial_mon {
  int count;
  struct {
    char serial[MK5_DISK_SERIAL_BYTES];
    struct m5state state;
  } serial[MK5_DISK_SERIAL_MAX];
  
};
