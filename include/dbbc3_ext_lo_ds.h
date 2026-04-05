/*
 * Copyright (c) 2026 NVI, Inc.
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
/* DBBC3 ext_lo data structures */

struct dbbc3_ext_lo_cmd {
  int count;
  struct dbbc3_ext_lo_table {
    int ifc;
    double freq;
    int sb;
    double lo_min;
    double lo_max;
    int lo_sb;
  } table[MAX_DBBC3_EXT_LO_TABLE];
};
