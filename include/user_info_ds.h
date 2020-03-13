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
/* header file for vlba st data structures */

struct user_info_parse {
  int field;             /* parsed field value */
  int label;             /* TRUE for label, FALSE for field */
  char string[49];       /* parsed string */
};

struct user_info_cmd {   /* command parameters */
  char labels[4][17];       /* label strings */
  char field1[17];       /* field1 string */
  char field2[17];       /* field2 string */
  char field3[33];       /* field3 string */
  char field4[49];       /* field4 string */
};
